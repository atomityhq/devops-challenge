output "instance_public_ip" {
  description = "Public IPv4 address of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port used to access the application."
  value       = var.app_port
}