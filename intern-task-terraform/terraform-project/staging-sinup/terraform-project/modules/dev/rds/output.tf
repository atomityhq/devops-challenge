output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "db_address" {
  description = "RDS hostname"
  value       = aws_db_instance.this.address
}

output "db_endpoint" {
  description = "RDS hostname and port"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.this.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN containing the master credentials"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}