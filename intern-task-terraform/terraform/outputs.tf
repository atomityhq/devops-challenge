output "instance_public_ip" {
  description = "Public IP address of the application EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port on which the application is running"
  value       = local.app_port
}
