locals {
  # Single source of truth: the instance builds the *same* Dockerfile/app as the
  # Kubernetes task, and the port is read from that Dockerfile's EXPOSE line, so
  # the security group, host firewall and container can never disagree.
  dockerfile = file("${path.module}/../../intern-task-app/Dockerfile")
  app_source = file("${path.module}/../../intern-task-app/app/app.py")
  app_port   = tonumber(regex("(?m)^EXPOSE\\s+(\\d+)", local.dockerfile)[0])

  user_data = templatefile("${path.module}/user_data.yaml.tftpl", {
    admin_username      = var.admin_username
    ssh_public_key      = var.ssh_public_key
    app_port            = local.app_port
    dockerfile_b64      = base64encode(local.dockerfile)
    app_source_b64      = base64encode(local.app_source)
    systemd_service_b64 = base64encode(templatefile("${path.module}/intern-task-app.service.tftpl", { app_port = local.app_port }))
  })
}

# ---------------------------------------------------------------- networking

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name}-vpc" }
}

# A subnet is only "public" if it has (1) an internet gateway on the VPC,
# (2) a route to that gateway, and (3) instances with public IPs.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = { Name = "${var.name}-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${var.name}-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Lock down the VPC's default security group so nothing can use it by accident.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
}

# ------------------------------------------------------------ security group

resource "aws_security_group" "app" {
  name        = "${var.name}-sg"
  description = "SSH from one CIDR and the app port from anywhere"
  vpc_id      = aws_vpc.this.id

  tags = { Name = "${var.name}-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the admin CIDR only"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "App port from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = local.app_port
  to_port           = local.app_port
}

# Outbound is limited to what bootstrap needs (apt over http/https, image pull
# and base-image download over https). DNS, metadata and time sync are not
# filtered by security groups.
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS out (docker image, packages)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP out (apt mirrors)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# ------------------------------------------------------------------ instance

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = local.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 12
    encrypted   = true
  }

  # Make sure the route to the internet exists before first boot, since the
  # bootstrap downloads packages and the base image immediately.
  depends_on = [aws_route_table_association.public]

  lifecycle {
    # cloud-init only runs user_data at first boot, so editing it can never
    # change a running instance. Without this, any edit to user_data (even an
    # unrelated variable that feeds into it) makes the provider plan a change to
    # the instance. To deliberately re-bootstrap, run:
    #   terraform apply -replace=aws_instance.app
    ignore_changes = [user_data]
  }

  tags = { Name = var.name }
}
