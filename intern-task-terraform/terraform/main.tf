provider "aws" {
  region = var.region

  # Plumbing so `terraform plan` works with fake credentials (nothing is deployed).
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

locals {
  dockerfile = file("${path.module}/../../intern-task-app/Dockerfile")
  app_py     = file("${path.module}/../../intern-task-app/app/app.py")

  # Single source of truth: read the port from the Dockerfile's ENV PORT=...
  app_port = tonumber(regex("PORT=(\\d+)", local.dockerfile)[0])

  systemd_unit = <<-EOT
    [Unit]
    Description=intern-task-app container
    After=docker.service network-online.target
    Requires=docker.service

    [Service]
    Restart=always
    RestartSec=5
    ExecStartPre=-/usr/bin/docker rm -f intern-task-app
    ExecStart=/usr/bin/docker run --rm --name intern-task-app -p ${local.app_port}:${local.app_port} intern-task-app:local
    ExecStop=/usr/bin/docker stop intern-task-app

    [Install]
    WantedBy=multi-user.target
  EOT

  cloud_config = {
    package_update = true
    packages       = ["docker.io", "ufw"]

    users = [{
      name                = var.admin_user
      sudo                = "ALL=(ALL) NOPASSWD:ALL"
      shell               = "/bin/bash"
      lock_passwd         = true
      ssh_authorized_keys = var.ssh_public_key == "" ? [] : [var.ssh_public_key]
    }]

    write_files = [
      {
        path        = "/opt/intern-task-app/Dockerfile"
        permissions = "0644"
        encoding    = "b64"
        content     = base64encode(local.dockerfile)
      },
      {
        path        = "/opt/intern-task-app/app/app.py"
        permissions = "0644"
        encoding    = "b64"
        content     = base64encode(local.app_py)
      },
      {
        path        = "/etc/systemd/system/intern-task-app.service"
        permissions = "0644"
        content     = local.systemd_unit
      },
    ]

    runcmd = [
      "systemctl enable --now docker",
      "docker build -t intern-task-app:local /opt/intern-task-app",
      "ufw default deny incoming",
      "ufw default allow outgoing",
      "ufw allow from ${var.ssh_cidr} to any port 22 proto tcp",
      "ufw allow ${local.app_port}/tcp",
      "ufw --force enable",
      "systemctl daemon-reload",
      "systemctl enable --now intern-task-app",
    ]
  }

  user_data = "#cloud-config\n${yamlencode(local.cloud_config)}"
}

# ---------------- Networking ----------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "intern-task-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "intern-task-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = { Name = "intern-task-public" }
}

# What actually makes the subnet public: a default route to the internet gateway...
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "intern-task-public-rt" }
}

# ...associated with the subnet.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name_prefix = "intern-task-app-"
  description = "SSH from one CIDR, app port from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the allowed CIDR only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "App port"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound is needed for apt and pulling the python base image.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "intern-task-app-sg" }
}

# ---------------- Instance ----------------

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = local.user_data

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    encrypted = true
  }

  # cloud-init only runs at first boot, so later user_data changes could never
  # reach a running instance. Ignore them instead of replacing the instance.
  lifecycle {
    ignore_changes = [user_data]
  }

  tags = { Name = "intern-task-app" }
}
