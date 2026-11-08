output "public_ip" {
  description = "Public IPv4 address of the instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port intern-task-app listens on (taken from its Dockerfile)."
  value       = local.app_port
}

output "app_url" {
  description = "URL of the running app."
  value       = "http://${aws_instance.app.public_ip}:${local.app_port}/"
}

output "ssh_command" {
  description = "SSH command for the admin user."
  value       = "ssh ${var.admin_username}@${aws_instance.app.public_ip}"
}
