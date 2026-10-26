output "instance_public_ip" {
  description = "Public IPv4 address of the application EC2 instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port used by the Python HTTP service."
  value       = var.app_port
}
