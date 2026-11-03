resource "aws_security_group" "app" {
  name        = "${local.app_name}-sg"
  description = "Allow restricted SSH and public application access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.app_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the supplied CIDR only"

  cidr_ipv4   = var.ssh_cidr
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "Public access to the application"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = local.app_port
  to_port     = local.app_port
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound access for package and image downloads"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}