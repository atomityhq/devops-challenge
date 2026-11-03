output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "app_port" {
  value = 5000
}