resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_user           = var.admin_user
    admin_ssh_public_key = var.admin_ssh_public_key
    ssh_cidr             = var.ssh_cidr
    app_port             = local.app_port
    dockerfile_b64       = base64encode(local.dockerfile)
    dockerignore_b64     = filebase64("${local.app_dir}/.dockerignore")
    app_py_b64           = filebase64("${local.app_dir}/app/app.py")
  })

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = { Name = "intern-task-app" }
}