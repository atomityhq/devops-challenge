# ---------- Network ----------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
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
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "intern-task-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- Security group (least privilege) ----------

resource "aws_security_group" "app" {
  name_prefix = "intern-task-"
  description = "SSH from one CIDR, app port from anywhere"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "intern-task-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the admin CIDR only"
  cidr_ipv4         = var.ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "App port from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

# Terraform removes AWS's default allow-all egress, so add it back.
# Without it the instance cannot download Docker or base images.
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound for package installs"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------- Instance ----------

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = templatefile("${path.module}/user_data.yaml.tpl", {
    admin_user     = var.admin_user
    ssh_public_key = var.ssh_public_key
    ssh_cidr       = var.ssh_cidr
    app_port       = var.app_port
    dockerfile_b64 = base64encode(file("${path.module}/../../intern-task-app/Dockerfile"))
    app_py_b64     = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))
  })

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "intern-task-app"
  }

  # cloud-init only runs at first boot, so a changed user_data can never
  # reach a running instance. Ignore it so unrelated edits don't touch the VM.
  lifecycle {
    ignore_changes = [user_data]
  }
}
