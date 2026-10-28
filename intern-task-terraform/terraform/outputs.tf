output "instance_public_ip" {
  description = "Public IP of the instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port the app listens on, read from intern-task-app's Dockerfile."
  value       = local.app_port
}