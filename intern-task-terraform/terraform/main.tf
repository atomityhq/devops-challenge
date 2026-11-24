
#  VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "intern-task-vpc"
  }
}



#  Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intern-task-igw"
  }
}



#  public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "intern-task-public-subnet"
  }
}


# public route table
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


# Associating the route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Security group
resource "aws_security_group" "app" {
  name        = "intern-task-security-group"
  description = "Allow restricted SSH and application traffic"
  vpc_id      = aws_vpc.main.id

  # SSH access from a specific CIDR only
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Application access
  ingress {
    description = "Application traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic for package downloads and application setup
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


# Creating an EC2 instance
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  user_data                   = file("${path.module}/user_data.sh")
  

  tags = {
    Name = "intern-task-ec2-test"
  }

  # Prevent user_data changes from forcing instance replacement
  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [
    aws_route_table_association.public
  ]
}
