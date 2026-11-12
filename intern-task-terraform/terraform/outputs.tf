output "instance_public_ip" {
  value       = aws_instance.web.public_ip
}
output "app_port" {
  value       = 5000
}