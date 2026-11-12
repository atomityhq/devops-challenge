
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
    dockerfile_b64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
    app_b64        = filebase64("${path.module}/../../intern-task-app/app/app.py")
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}
