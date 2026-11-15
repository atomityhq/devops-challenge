locals {
  app_port = 5000
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    dockerfile = filebase64("${path.module}/../../intern-task-app/Dockerfile")
    app_source = filebase64("${path.module}/../../intern-task-app/app/app.py")
    app_port   = local.app_port
  })
}

resource "aws_vpc" "app" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name}-public" }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name_prefix = "intern-task-app-"
  description = "App access and SSH restricted to the operator CIDR"
  vpc_id      = aws_vpc.app.id
  ingress {
    description = "App"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Trusted SSH CIDR (host firewall remains app-only)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
  egress {
    description = "Package installation, DNS and image downloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data                   = local.user_data
  user_data_replace_on_change = false
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }
  tags = { Name = var.name }

  # cloud-init runs once. Do not pretend subsequent source changes update a live host.
  # An intentional bootstrap rollout requires terraform apply -replace=aws_instance.app.
  lifecycle {
    ignore_changes = [user_data]
  }
  depends_on = [aws_route_table_association.public]
}
