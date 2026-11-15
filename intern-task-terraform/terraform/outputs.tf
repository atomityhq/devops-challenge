output "public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.app.public_ip
}

output "app_port" {
  description = "Port HTTP de l'application"
  value       = 5000
}