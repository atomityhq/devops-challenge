output "instance_public_ip" {
  description = "Public IP of the instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port intern-task-app listens on, read from its Dockerfile."
  value       = local.app_port
}

output "app_url" {
  description = "URL of the app."
  value       = "http://${aws_instance.app.public_ip}:${local.app_port}"
}