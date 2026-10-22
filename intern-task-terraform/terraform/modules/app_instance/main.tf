resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SSH from one CIDR, app port from anywhere."
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.this.id
  description       = "SSH from the allowed CIDR only"
  cidr_ipv4         = var.ssh_allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.this.id
  description       = "App port from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.app_port
  to_port           = var.app_port
}

# Egress is limited to what bootstrap needs: apt (HTTP/HTTPS) and pulling the
# base image from Docker Hub (HTTPS). DNS and NTP go to the VPC's link-local
# Amazon services, which security groups don't filter.
resource "aws_vpc_security_group_egress_rule" "web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.this.id
  description       = "Outbound TCP ${each.value}"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  user_data                   = var.user_data

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  lifecycle {
    # cloud-init consumes user_data once, at first boot; a running instance
    # can never apply a new version. Ignoring it keeps unrelated changes from
    # forcing a replace. Roll out a new bootstrap deliberately with:
    #   terraform apply -replace=module.app_instance.aws_instance.this
    ignore_changes = [user_data]
  }

  tags = { Name = var.name }
}
