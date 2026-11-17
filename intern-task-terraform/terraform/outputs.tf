output "public_ip" {
  description = "Public IPv4 address assigned to the application instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port used by the application."
  value       = local.app_port
}