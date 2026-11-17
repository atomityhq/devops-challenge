resource "aws_security_group" "app" {
  name        = "intern-task-app-sg"
  description = "Security group for intern-task-app"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from restricted CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Application HTTP traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "intern-task-app-sg"
  }
}