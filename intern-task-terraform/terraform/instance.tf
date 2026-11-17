resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.app.id]

  user_data = local.app_user_data

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "intern-task-app"
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [
    aws_route_table_association.public,
    aws_vpc_security_group_ingress_rule.ssh,
    aws_vpc_security_group_ingress_rule.app,
    aws_vpc_security_group_egress_rule.outbound
  ]
}