locals {
  app_port = var.app_port
}

resource "aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "intern-task-app-vpc"
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "intern-task-app-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-app-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "intern-task-app-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "intern-task-app"
  description = "Allow SSH from a specific CIDR and access to the app"
  vpc_id      = aws_vpc.app.id

  ingress {
    description = "SSH from the configured source"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "intern-task-app"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "intern-task-app"
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/cloud-init.sh.tpl", {
    app_port          = var.app_port
    ssh_cidr          = var.ssh_cidr
    dockerfile_base64 = base64encode(file("${path.module}/../../intern-task-app/Dockerfile"))
    app_source_base64 = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))
  })

  user_data_replace_on_change = false

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}
