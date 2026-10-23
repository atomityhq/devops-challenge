resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.yaml.tftpl", {
    admin_user     = var.admin_user
    app_port       = var.app_port
    dockerfile_b64 = base64encode(replace(file("${path.module}/../../intern-task-app/Dockerfile"), "\r\n", "\n"))
    app_b64        = base64encode(replace(file("${path.module}/../../intern-task-app/app/app.py"), "\r\n", "\n"))
  })

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}
