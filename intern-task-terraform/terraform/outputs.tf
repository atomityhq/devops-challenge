output "public_ip" {
  description = "Public IPv4 address of the application instance."
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Application TCP port, matching the Dockerfile."
  value       = local.app_port
}

output "instance_id" {
  description = "Instance identity, also used to verify stability in mocked lifecycle tests."
  value       = aws_instance.app.id
}
