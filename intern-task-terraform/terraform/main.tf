resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = local.app_user_data

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [
    aws_route_table_association.public,
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${var.project_name}-app"
  }
}
