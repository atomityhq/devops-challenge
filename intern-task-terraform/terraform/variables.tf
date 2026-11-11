
variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID."
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "CIDR allowed to access the instance through SSH."
  type        = string
}

variable "app_port" {
  description = "Port used by the application."
  type        = number
  default     = 8080
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet."
  type        = string
  default     = "us-east-1a"
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
  default     = "intern-task"
}