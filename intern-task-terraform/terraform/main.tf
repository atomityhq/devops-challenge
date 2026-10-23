provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
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
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
    #!/bin/bash
    useradd -m -s /bin/bash appuser
    echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appuser

    apt-get update -y && apt-get install -y docker.io git ufw

    ufw default deny incoming
    ufw allow 5000/tcp
    ufw --force enable

    git clone -b feature/containerize-app https://github.com/jaikumargaja/devops-challenge-atomity.git /opt/app
    cd /opt/app/intern-task-app
    docker build -t intern-task-app:local .

    cat << 'SVC' > /etc/systemd/system/app.service
    [Unit]
    Description=App
    After=docker.service
    [Service]
    ExecStart=/usr/bin/docker run --rm -p 5000:5000 intern-task-app:local
    [Install]
    WantedBy=multi-user.target
    SVC

    systemctl enable --now app.service
  EOF

  lifecycle {
    ignore_changes = [user_data]
  }
}