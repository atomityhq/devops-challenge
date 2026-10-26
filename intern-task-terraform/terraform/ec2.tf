
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  associate_public_ip_address = true

  user_data = templatefile(
    "${path.module}/cloud-init.sh.tftpl",
    {
      app_port       = var.app_port
      ssh_cidr       = var.ssh_allowed_cidr
      dockerfile_b64 = base64encode(file("${path.module}/../../intern-task-app/Dockerfile"))
      app_b64        = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))
    }
  )

  user_data_replace_on_change = false

  lifecycle {
    ignore_changes = [user_data]
  }

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }

  depends_on = [
    aws_route_table_association.public
  ]
}
