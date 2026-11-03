output "public_ip" {
  description = "Public IPv4 address of the application instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "TCP port used by the application."
  value       = local.app_port
}