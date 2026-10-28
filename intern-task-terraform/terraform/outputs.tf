
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port on which the application listens."
  value       = 5000
}

