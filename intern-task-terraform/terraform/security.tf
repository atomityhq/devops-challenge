resource "aws_security_group" "app" {
  name        = "intern-task-app"
  description = "Least-privilege access for the intern-task application instance."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the configured administrative network"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Public application traffic"
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow package and Docker image downloads"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "intern-task-app-sg"
  }
}
