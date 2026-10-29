locals {
  app_port = 8080
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "intern-task-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-public-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intern-task-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "intern-task-public-routes"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "intern-task-app-sg"
  description = "Allow restricted SSH and public app access."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the configured CIDR only."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Application HTTP traffic."
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic for package installation and image builds."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "intern-task-app-sg"
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    dockerfile_b64   = filebase64("${path.module}/../../intern-task-app/Dockerfile")
    app_py_b64       = filebase64("${path.module}/../../intern-task-app/app/app.py")
    app_port         = local.app_port
    ssh_allowed_cidr = var.ssh_allowed_cidr
  })

  # cloud-init runs at first boot. Ignore later user_data changes so they
  # cannot trigger an instance replacement during an unrelated plan.
  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}
