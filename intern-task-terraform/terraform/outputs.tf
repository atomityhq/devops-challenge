output "public_ip" {
  description = "Public IPv4 address of the application instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port on which the application is exposed."
  value       = local.app_port
}
