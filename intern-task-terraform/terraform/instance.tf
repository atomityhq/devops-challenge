resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = local.user_data

  tags = {
    Name = "${var.name_prefix}-instance"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}