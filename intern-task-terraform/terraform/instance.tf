resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_user       = var.admin_user
    ssh_keys         = var.admin_ssh_public_key == null ? [] : [var.admin_ssh_public_key]
    ssh_allowed_cidr = var.ssh_allowed_cidr
    app_port         = local.app_port
    dockerfile_b64   = filebase64("${local.app_dir}/Dockerfile")
    app_py_b64       = filebase64("${local.app_dir}/app/app.py")
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = { Name = "intern-task-app" }
}