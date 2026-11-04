# Provision an EC2 instance to host the Docker application.
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Place the instance in our public subnet.
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  # Bootstrap the instance using the real application files.
 user_data = templatefile("${path.module}/bootstrap.sh", {
  ssh_cidr       = var.ssh_cidr
  dockerfile_b64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
  app_b64        = filebase64("${path.module}/../../intern-task-app/app/app.py")
})
  # Cloud-init runs at first boot. Ignore later user_data changes
  # to prevent unnecessary instance updates or replacement.
  lifecycle {
    ignore_changes = [user_data]
  }

  # Ensure internet routing exists before the instance boots.
  depends_on = [aws_route_table_association.public]

  tags = {
    Name = "intern-task-app"
  }
}
