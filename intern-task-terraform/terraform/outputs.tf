# Display the public IP address of the EC2 instance.
output "instance_public_ip" {
  description = "Public IP address of the application server"
  value       = aws_instance.app.public_ip
}

# Display the port used by the Python application.
output "app_port" {
  description = "Port on which the application listens"
  value       = 8080
}
