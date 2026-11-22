output "instance_public_ip" {
  description = "Public IP address of the application EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port exposed by the application"
  value       = 8080
}
