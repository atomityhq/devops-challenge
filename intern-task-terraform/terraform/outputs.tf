output "instance_public_ip" {
  description = "Public IP of the app instance."
  value       = module.app_instance.public_ip
}

output "app_port" {
  description = "Port the app listens on (parsed from intern-task-app's Dockerfile)."
  value       = local.app_port
}

output "app_url" {
  description = "Convenience URL for the app's health endpoint."
  value       = "http://${module.app_instance.public_ip}:${local.app_port}/healthz"
}
