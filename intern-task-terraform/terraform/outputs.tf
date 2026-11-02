output "instance_public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "TCP port on which the application listens."
  value       = 5000
}