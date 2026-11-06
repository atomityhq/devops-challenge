variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the instance (never launched, any plausible value works)"
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_port" {
  description = "Port intern-task-app listens on (matches ENV PORT in its Dockerfile)"
  type        = number
  default     = 8080
}

variable "ssh_cidr" {
  description = "Single CIDR allowed to SSH to the instance. No default on purpose."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "Provide a valid, specific CIDR range for SSH. Do not use 0.0.0.0/0."
  }
}