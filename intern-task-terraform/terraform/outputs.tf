output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "app_port" {
  value = var.app_port
}