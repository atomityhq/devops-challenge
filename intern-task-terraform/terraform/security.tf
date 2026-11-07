locals {
  app_port = 8080
}

resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-"
  description = "Allow restricted SSH and public application access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the specified CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Application HTTP access"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound access for installation and image builds"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
