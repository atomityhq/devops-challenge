
# ---------------------------------------
# 1. VPC
# ---------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "intern-task-vpc"
  }
}

# ---------------------------------------
# 2. Public Subnet
# ---------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-public-subnet"
  }
}

# ---------------------------------------
# 3. Internet Gateway
# ---------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intern-task-igw"
  }
}

# ---------------------------------------
# 4. Public Route Table
# ---------------------------------------

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

# ---------------------------------------
# 5. Route Table Association
# ---------------------------------------

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------
# 6. Security Group
# ---------------------------------------

resource "aws_security_group" "app" {
  name        = "intern-task-security-group"
  description = "Restricted SSH and public application access"
  vpc_id      = aws_vpc.main.id

  # SSH only from the supplied CIDR
  ingress {
    description = "Restricted SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Application accessible publicly
  ingress {
    description = "Application HTTP access"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "intern-task-security-group"
  }
}

# ---------------------------------------
# 7. EC2 Instance
# ---------------------------------------

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    app_source = file("${path.module}/../../intern-task-app/app/app.py")
    dockerfile = file("${path.module}/../../intern-task-app/Dockerfile")
    app_port   = var.app_port
    ssh_cidr   = var.ssh_cidr
  })

  # Prevent user_data changes from forcing instance replacement.
  user_data_replace_on_change = false

  tags = {
    Name = "intern-task-app-server"
  }
}
