locals {
  user_data = replace(templatefile("${path.module}/cloud-init.yaml.tftpl", {
    app_name       = local.app_name
    app_port       = local.app_port
    dockerfile_b64 = base64encode(replace(file("${path.module}/../../intern-task-app/Dockerfile"), "\r\n", "\n"))
    app_source_b64 = base64encode(replace(file("${path.module}/../../intern-task-app/app/app.py"), "\r\n", "\n"))
  }), "\r\n", "\n")
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data                   = local.user_data
  user_data_replace_on_change = false

  depends_on = [
    aws_route.internet,
    aws_route_table_association.public,
    aws_vpc_security_group_egress_rule.outbound,
  ]

  tags = {
    Name = local.app_name
  }
}