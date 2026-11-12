resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/bootstrap/user_data.sh.tftpl", {
    dockerfile_b64 = filebase64("${path.module}/bootstrap/Dockerfile")
    app_source_b64 = filebase64("${path.module}/bootstrap/app/app.py")
    ssh_cidr       = var.ssh_cidr
    app_port       = var.app_port
  })

  # Do not replace the EC2 instance when user_data changes.
  # Cloud-init runs user_data during initial instance boot.
  user_data_replace_on_change = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "intern-task-app-instance"
    Environment = "challenge"
  }

  # Ensure internet routing exists before cloud-init starts installing packages.
  depends_on = [
    aws_route_table_association.public
  ]
}
