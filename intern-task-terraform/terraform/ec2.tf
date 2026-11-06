
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
    app_port       = local.app_port
    ssh_cidr       = var.ssh_cidr
    dockerfile_b64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
    app_b64        = filebase64("${path.module}/../../intern-task-app/app/app.py")
  })

  # Prevent instance replacement when user_data changes.
  user_data_replace_on_change = false

  # Ensure public routing is configured before EC2 boots.
  depends_on = [
    aws_route_table_association.public
  ]

  tags = {
    Name = "intern-task-ec2"
  }
}
