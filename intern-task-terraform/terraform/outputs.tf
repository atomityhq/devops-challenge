
output "public_ip" {
  description = "Public IP of the application EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Application listening port"
  value       = local.app_port
}
