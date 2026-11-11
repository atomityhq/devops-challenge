output "public_ip" {
  description = "Public IPv4 address of the instance."
  value       = aws_instance.this.public_ip
}

output "app_port" {
  description = "Port the application listens on, and the only port the security group and the host firewall expose."
  value       = var.app_port
}
