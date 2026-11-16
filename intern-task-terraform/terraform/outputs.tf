output "public_ip" {
  description = "Public IP of the instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port the app listens on (read from the Dockerfile's EXPOSE)."
  value       = local.app_port
}
