terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "intern-task-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intern-task-igw"
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

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "intern-task-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app_sg" {
  name   = "intern-task-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "intern-task-sg"
  }
}

resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  user_data_replace_on_change = false

  user_data = <<-EOF
  #!/bin/bash
  set -euo pipefail

  useradd -m -s /bin/bash apprunner
  echo "apprunner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/apprunner

  apt-get update -y
  apt-get install -y docker.io ufw
  systemctl enable --now docker
  usermod -aG docker apprunner

  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 5000/tcp
  ufw --force enable

  mkdir -p /opt/app/app
  cat << 'DOCKERFILE' > /opt/app/Dockerfile
  FROM python:3.12-alpine
  ENV PYTHONUNBUFFERED=1 PORT=5000
  WORKDIR /app
  RUN addgroup -S appgroup && adduser -S appuser -G appgroup
  COPY app/app.py ./
  RUN chown -R appuser:appgroup /app
  USER appuser
  EXPOSE 5000
  CMD ["python", "app.py"]
  DOCKERFILE

  cat << 'APPPY' > /opt/app/app/app.py
  import os
  from http.server import HTTPServer, BaseHTTPRequestHandler

  PORT = int(os.environ.get("PORT", 5000))

  class Handler(BaseHTTPRequestHandler):
      def do_GET(self):
          if self.path == "/healthz":
              self.send_response(200)
              self.send_header("Content-Type", "text/plain")
              self.end_headers()
              self.wfile.write(b"ok")
          else:
              self.send_response(200)
              self.send_header("Content-Type", "text/plain")
              self.end_headers()
              self.wfile.write(b"hello from intern-task")

  if __name__ == "__main__":
      server = HTTPServer(("0.0.0.0", PORT), Handler)
      server.serve_forever()
  APPPY

  cd /opt/app
  docker build -t intern-task-app:local .

  cat << 'SERVICE' > /etc/systemd/system/intern-task-app.service
  [Unit]
  Description=Intern Task App Container
  After=docker.service
  Requires=docker.service

  [Service]
  Restart=always
  ExecStartPre=-/usr/bin/docker stop intern-task-app
  ExecStartPre=-/usr/bin/docker rm intern-task-app
  ExecStart=/usr/bin/docker run --name intern-task-app -p 5000:5000 intern-task-app:local
  ExecStop=/usr/bin/docker stop intern-task-app

  [Install]
  WantedBy=multi-user.target
  SERVICE

  systemctl daemon-reload
  systemctl enable --now intern-task-app.service
  EOF

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-ec2"
  }
}