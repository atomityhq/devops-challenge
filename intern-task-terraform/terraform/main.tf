locals {
  # The app being deployed is the real intern-task-app, read straight from
  # the sibling task so the two can't drift apart.
  app_dir    = "${path.module}/../../intern-task-app"
  dockerfile = file("${local.app_dir}/Dockerfile")

  # The port is whatever the Dockerfile says, not a separate setting here.
  # Read EXPOSE, and also the PORT env the app actually binds to, and refuse
  # to plan if they disagree (see the precondition on aws_instance.app).
  app_port     = tonumber(regex("(?m)^EXPOSE\\s+(\\d+)", local.dockerfile)[0])
  app_env_port = tonumber(regex("(?m)\\bPORT=(\\d+)", local.dockerfile)[0])

  # Exactly the build context the other task uses: Dockerfile,
  # .dockerignore and app/ (minus local bytecode caches).
  app_files = {
    for f in concat(
      ["Dockerfile", ".dockerignore"],
      [for p in fileset(local.app_dir, "app/**") : p if !strcontains(p, "__pycache__")],
    ) : f => filebase64("${local.app_dir}/${f}")
  }

  image_tag = "intern-task-app:local"

  systemd_unit = templatefile("${path.module}/templates/intern-task-app.service.tftpl", {
    image_tag = local.image_tag
    app_port  = local.app_port
    build_dir = "/opt/intern-task-app"
  })

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    admin_username = var.admin_username
    ssh_public_key = var.ssh_public_key
    ssh_cidr       = var.ssh_cidr
    app_port       = local.app_port
    app_files      = local.app_files
    systemd_unit   = base64encode(local.systemd_unit)
    build_dir      = "/opt/intern-task-app"
  })
}

# ---------------------------------------------------------------------------
# Networking: a VPC with one subnet that is actually public.
#
# A subnet is "public" only if all of these hold:
#   1. the VPC has an Internet Gateway attached,
#   2. the subnet's route table sends 0.0.0.0/0 to that IGW
#      (a fresh VPC's main route table only has the local route),
#   3. the instance has a public IPv4 address.
# ---------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = { Name = "${var.name}-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.name}-public" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Security group: SSH from one CIDR, the app port from anywhere, nothing else
# inbound. Egress is limited to what bootstrapping needs (apt and the Docker
# Hub pull of the python base image are HTTP/HTTPS). DNS to the VPC resolver
# and NTP to the Amazon Time Sync Service are not filtered by security
# groups, so they need no rule.
# ---------------------------------------------------------------------------

resource "aws_security_group" "app" {
  # name and description are both immutable in AWS (changing either forces
  # replacement), so keep variable values out of the description, and use
  # name_prefix + create_before_destroy so a rename swaps the instance onto
  # a new group instead of failing to delete one that's still attached.
  name_prefix = "${var.name}-app-"
  description = "intern-task-app instance: SSH from admin CIDR, app port from anywhere"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.name}-app" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the admin CIDR only"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "intern-task-app from anywhere"
  ip_protocol       = "tcp"
  from_port         = local.app_port
  to_port           = local.app_port
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.app.id
  description       = "Outbound TCP ${each.key} for apt and Docker Hub"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# The instance, bootstrapped entirely by cloud-init.
# ---------------------------------------------------------------------------

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = local.user_data

  metadata_options {
    http_tokens   = "required" # IMDSv2 only
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 16
    encrypted   = true
  }

  tags = { Name = "${var.name}-app" }

  # The IGW must exist before the instance boots, or cloud-init's apt and
  # docker build run with no route out. Nothing in the instance's arguments
  # references the IGW or route, so Terraform wouldn't infer this ordering.
  depends_on = [aws_route.public_internet, aws_route_table_association.public]

  lifecycle {
    # user_data is consumed by cloud-init exactly once, at first boot.
    # Changing it on a running instance can't change what that instance
    # did at boot, so a diff here is either a replacement nobody asked for
    # or an in-place update that does nothing. Ignore it after creation;
    # to roll out new user_data deliberately, run:
    #   terraform apply -replace=aws_instance.app
    ignore_changes = [user_data]

    precondition {
      condition     = local.app_port == local.app_env_port
      error_message = "intern-task-app's Dockerfile EXPOSEs ${local.app_port} but sets PORT=${local.app_env_port}; the app binds to PORT, so fix the Dockerfile before deploying."
    }
  }
}
