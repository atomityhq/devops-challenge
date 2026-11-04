locals {
  app_src = "${path.module}/../../intern-task-app"
  user_data = templatefile("${path.module}/user_data.yaml.tftpl", {
    admin_user     = var.admin_user
    ssh_public_key = var.ssh_public_key
    app_port       = var.app_port
    dockerfile_b64 = base64encode(file("${local.app_src}/Dockerfile"))
    app_py_b64     = base64encode(file("${local.app_src}/app/app.py"))
  })
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 10
  }

  tags = {
    Name = "${var.name_prefix}-app"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [aws_route_table_association.public]
}