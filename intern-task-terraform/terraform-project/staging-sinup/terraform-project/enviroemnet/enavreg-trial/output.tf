output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_eip_addresses" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_eip_addresses
}
/*output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.vpc.database_subnet_ids
} */


/*### Ec2 instance output ####
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = module.ec2.private_ip
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = module.ec2.security_group_id
}

output "ec2_data_volume_id" {
  description = "Additional EBS volume ID"
  value       = module.ec2.data_volume_id
}

output "backup_vault_name" {
  description = "AWS Backup vault"
  value       = module.ec2.backup_vault_name
}

output "backup_plan_id" {
  description = "AWS Backup plan"
  value       = module.ec2.backup_plan_id
}
/*output "instance_id" {
  value = aws_instance.this.id
} */
/*output "public_subnet_ids" {
  value = aws_subnet.public[*].id
} */