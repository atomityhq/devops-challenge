resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "intern-task-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intern-task-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "intern-task-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "intern-task-app-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Application"
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
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
set -e

useradd -m -s /bin/bash appuser || true

echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appuser

apt-get update
apt-get install -y docker.io ufw

systemctl enable docker
systemctl start docker

ufw --force reset
ufw allow 22/tcp
ufw allow ${var.app_port}/tcp
ufw --force enable

mkdir -p /opt/intern-task-app

cat > /opt/intern-task-app/app.py <<'PYTHON'
import http.server
import os

PORT = int(os.environ.get("PORT", "5000"))

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/healthz":
            body = b"ok\\n"
        else:
            body = b"hello from intern-task\\n"

        self.send_response(200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass

if __name__ == "__main__":
    http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
PYTHON

cat > /opt/intern-task-app/Dockerfile <<'DOCKER'
FROM python:3.12-slim

RUN useradd -m appuser

WORKDIR /app

COPY app.py .

USER appuser

ENV PORT=5000

EXPOSE 5000

CMD ["python", "app.py"]
DOCKER

cd /opt/intern-task-app
docker build -t intern-task-app:local .

cat > /etc/systemd/system/intern-task-app.service <<'SERVICE'
[Unit]
Description=Intern Task App
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --name intern-task-app -p 5000:5000 intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app
[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable intern-task-app
systemctl start intern-task-app
EOF

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}