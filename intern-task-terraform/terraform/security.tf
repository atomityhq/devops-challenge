
resource "aws_security_group" "app" {
  name        = "intern-task-sg"
  description = "Security group for the intern task app"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "intern-task-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from allowed network"
  cidr_ipv4         = var.ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "Python application"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound connections"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
