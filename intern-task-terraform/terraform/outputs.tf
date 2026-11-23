output "public_ip" {
  description = "Public IPv4 address of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Application TCP port declared in the Dockerfile."
  value       = local.app_port
}
