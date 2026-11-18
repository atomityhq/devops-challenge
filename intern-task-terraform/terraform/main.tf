
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "intern-task-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intern-task-igw"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-subnet"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "intern-task-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
resource "aws_security_group" "app" {
  name        = "intern-task-app"
  description = "Security group for intern task application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "intern-task-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the admin CIDR only"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "intern-task-app"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = local.app_port
  to_port           = local.app_port
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTP for apt packages"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTPS for Docker Hub and repos"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

locals {
  app_port = tonumber(regex("(?m)^ENV PORT=([0-9]+)", file("${path.module}/../../intern-task-app/Dockerfile"))[0])

  dockerfile_b64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
  app_source_b64 = filebase64("${path.module}/../../intern-task-app/app/app.py")

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_username      = var.admin_username
    ssh_authorized_keys = jsonencode(compact([var.ssh_public_key]))
    ssh_allowed_cidr    = var.ssh_allowed_cidr
    app_port            = local.app_port
    dockerfile_b64      = local.dockerfile_b64
    app_source_b64      = local.app_source_b64
  })
}
resource "aws_instance" "app" {
  user_data_replace_on_change = false
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  tags = {
    Name = "intern-task-app"
  }
}
