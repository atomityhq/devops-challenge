
terraform {
  required_version = ">= 1.5.0"

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

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID for us-east-1"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP CIDR, for example 203.0.113.10/32"
  type        = string
}

variable "app_port" {
  type    = number
  default = 8080
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
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
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "intern-task-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "intern-task-app-sg"
  description = "Restricted SSH and application access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from specified CIDR only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Application port"
    from_port   = var.app_port
    to_port     = var.app_port
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
    Name = "intern-task-app-sg"
  }
}

locals {
  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io ufw

    id devops || useradd -m -s /bin/bash devops
    usermod -aG sudo,docker devops
    echo 'devops ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devops
    chmod 0440 /etc/sudoers.d/devops

    systemctl enable --now docker

    mkdir -p /opt/intern-task-app/app
    cat > /opt/intern-task-app/app/app.py <<'PYAPP'
    import http.server
    import os

    PORT = int(os.environ.get("PORT", "5000"))

    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/healthz":
                body = b"ok\n"
            else:
                body = b"hello from intern-task\n"
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, fmt, *args):
            pass

    if __name__ == "__main__":
        print(f"listening on 0.0.0.0:{PORT}", flush=True)
        http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
    PYAPP

    cat > /opt/intern-task-app/Dockerfile <<'DOCKER'
    FROM python:3.12-slim
    ENV PORT=8080
    WORKDIR /app
    COPY app/app.py .
    RUN useradd --system --no-create-home appuser \
        && chown appuser /app/app.py
    USER appuser
    EXPOSE 8080
    CMD ["python", "-u", "app.py"]
    DOCKER

    cd /opt/intern-task-app
    docker build -t intern-task-app:local .

    cat > /etc/systemd/system/intern-task-app.service <<'SERVICE'
    [Unit]
    Description=Intern Task App Docker Container
    Requires=docker.service
    After=docker.service

    [Service]
    Restart=always
    ExecStartPre=-/usr/bin/docker rm -f intern-task-app
    ExecStart=/usr/bin/docker run --name intern-task-app --rm -p 8080:8080 intern-task-app:local
    ExecStop=/usr/bin/docker stop intern-task-app
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    SERVICE

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow from ${var.ssh_allowed_cidr} to any port 22 proto tcp
    ufw allow 8080/tcp
    ufw --force enable

    systemctl daemon-reload
    systemctl enable --now intern-task-app.service
  USERDATA
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}

output "instance_public_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP address of the instance"
}

output "app_port" {
  value       = var.app_port
  description = "Application listening port"
}
