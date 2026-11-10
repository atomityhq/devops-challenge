output "instance_public_ip" {
  description = "Public IPv4 address assigned to the application EC2 instance."
  value       = aws_instance.app.public_ip
}

output "application_port" {
  description = "TCP port exposed by the intern-task application."
  value       = var.app_port
}
