output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "EC2 instance ARN"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2.id
}

output "iam_role_name" {
  description = "EC2 IAM role name"
  value       = aws_iam_role.ec2.name
}

output "instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}

output "root_volume_size" {
  description = "Root EBS volume size"
  value       = var.root_volume_size
}

output "data_volume_id" {
  description = "Additional EBS volume ID"
  value       = aws_ebs_volume.data.id
}

output "backup_vault_name" {
  description = "AWS Backup vault name"
  value       = aws_backup_vault.this.name
}

output "backup_plan_id" {
  description = "AWS Backup plan ID"
  value       = aws_backup_plan.this.id
}
