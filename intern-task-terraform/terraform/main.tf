locals {
  app_name    = "intern-task-app"
  admin_user  = "atomityadmin"
  app_context = "/opt/${local.app_name}"
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    admin_user     = local.admin_user
    app_name       = local.app_name
    app_context    = local.app_context
    app_port       = var.app_port
    ssh_cidr       = var.ssh_allowed_cidr
    dockerfile_b64 = base64encode(file("${path.module}/../../intern-task-app/Dockerfile"))
    app_py_b64     = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))
  })

  # cloud-init runs only on first boot. Keep the instance in place when this
  # rendered bootstrap changes; future bootstrap changes can be applied via a
  # deliberate instance refresh or configuration-management process.
  user_data_replace_on_change = false

  tags = {
    Name = local.app_name
  }
}
