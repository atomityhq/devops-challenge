terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

resource "aws_vpc" "app" {
  cidr_block = "10.42.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = true
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

variable "ssh_cidr" {
  description = "Plage IPv4 autorisée à accéder au port SSH"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && try(tonumber(split("/", var.ssh_cidr)[1]) > 0, false)
    error_message = "Indique une plage IPv4 valide et plus restrictive que /0."
  }
}

resource "aws_security_group" "app" {
  name   = "intern-task-app"
  vpc_id = aws_vpc.app.id

  ingress {
    description = "SSH depuis la plage autorisee"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP access to the application"
    protocol    = "tcp"
    from_port   = 5000
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound access for Docker installation and image downloads"
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

  user_data = templatefile("${path.module}/cloud-init.sh.tftpl", {
    app_port          = 5000
    dockerfile_base64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
    app_base64        = filebase64("${path.module}/../../intern-task-app/app/app.py")
    instance_name     = var.instance_name
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [aws_route_table_association.public]

  tags = {
    Name = var.instance_name
  }
}