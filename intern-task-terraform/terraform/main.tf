terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

locals {
  app_dir    = "${path.module}/../../intern-task-app"
  dockerfile = file("${local.app_dir}/Dockerfile")
  app_port   = tonumber(regex("(?m)^EXPOSE ([0-9]+)$", local.dockerfile)[0])
}

resource "aws_vpc" "app" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.app.id
  cidr_block = "10.20.1.0/24"
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
  name_prefix = "intern-task-"
  description = "App traffic and scoped SSH"
  vpc_id      = aws_vpc.app.id

  ingress {
    description = "SSH from the operator network"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Public application traffic"
    protocol    = "tcp"
    from_port   = local.app_port
    to_port     = local.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic for bootstrap and image builds"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.app.id]

  metadata_options {
    http_tokens = "required"
  }

  user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
    app_port   = local.app_port
    dockerfile = base64encode(local.dockerfile)
    app_source = filebase64("${local.app_dir}/app/app.py")
  })

  # Bootstrap is first-boot configuration. Later edits apply to new instances.
  lifecycle {
    ignore_changes = [user_data]
  }

  # Ensure the subnet's default route is in place before cloud-init runs.
  depends_on = [aws_route_table_association.public]

  tags = {
    Name = var.instance_name
  }
}
