output "instance_public_ip" {
  description = "Public IP of the app instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port the app listens on."
  value       = local.app_port
}