locals {
  app_source_dir = "${path.module}/../../intern-task-app"

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    admin_user       = var.admin_user
    app_port         = var.app_port
    ssh_allowed_cidr = var.ssh_allowed_cidr
    dockerfile_b64   = base64encode(file("${local.app_source_dir}/Dockerfile"))
    app_py_b64       = base64encode(file("${local.app_source_dir}/app/app.py"))
  })
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data                   = local.user_data
  user_data_replace_on_change = false

  tags = {
    Name = var.project_name
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}
