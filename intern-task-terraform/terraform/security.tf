
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-sg-"
  description = "Restricted SSH and application traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id

  description = "SSH access from trusted admin IP"
  cidr_ipv4   = var.ssh_allowed_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id

  description = "Public application HTTP access"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.app_port
  to_port     = var.app_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.app.id

  description = "Outbound connectivity for packages and image build"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
