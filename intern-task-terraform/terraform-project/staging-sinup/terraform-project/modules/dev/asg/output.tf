output "autoscaling_group_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.this.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.this.id
}
