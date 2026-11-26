
# Output the EC2 instance public IP address
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

# Output the application port
output "app_port" {
  description = "Port on which the application listens"
  value       = var.app_port
}
