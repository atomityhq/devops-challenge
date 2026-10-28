resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = local.user_data

  tags = {
    Name = "intern-task-app"
  }

  lifecycle {
    # cloud-init only runs user_data on first boot, so changes can't be
    # applied to a running instance. Use `terraform apply -replace` to
    # roll out a new user_data deliberately.
    ignore_changes = [user_data]
  }
}