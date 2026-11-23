locals {
  app_port = 5000
  app_dir  = "${path.module}/../../intern-task-app"
}

resource "aws_vpc" "app" {
  cidr_block = "10.24.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.app.id
  cidr_block = "10.24.1.0/24"
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
  vpc_id = aws_vpc.app.id

  ingress {
    description = "Public HTTP service"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Restricted SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
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
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.app.id]
  depends_on                  = [aws_route_table_association.public]

  user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
    app_port   = local.app_port
    dockerfile = filebase64("${local.app_dir}/Dockerfile")
    app_source = filebase64("${local.app_dir}/app/app.py")
  })
  user_data_replace_on_change = false
}
