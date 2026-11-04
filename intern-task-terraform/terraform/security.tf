# Security group for the intern-task-app EC2 instance.
resource "aws_security_group" "app" {
  name        = "intern-task-app-sg"
  description = "Restrict SSH and allow application traffic"
  vpc_id      = aws_vpc.main.id


  # Allow SSH only from the trusted CIDR provided by the user.
  ingress {
    description = "SSH from trusted network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }


  # Allow public HTTP access to the application on port 8080.
  ingress {
    description = "Application access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound connections for system updates,
  # Docker installation, and downloading application source.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
