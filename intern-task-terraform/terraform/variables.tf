variable "aws_region" {
  description = "AWS region. Never contacted in this exercise."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI for the instance (Ubuntu; user_data uses apt). Placeholder value, never launched."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_cidr" {
  description = "The single CIDR allowed to SSH in, e.g. 203.0.113.10/32. Required: no sane default exists."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "ssh_cidr must be a valid CIDR and must not be 0.0.0.0/0."
  }
}

variable "ssh_public_key" {
  description = "Public key installed for the non-root admin user. Leave empty to skip."
  type        = string
  default     = ""
}

variable "admin_user" {
  description = "Non-root user created on the instance (passwordless sudo)."
  type        = string
  default     = "deploy"
}

variable "app_port" {
  description = "Port the app listens on. Must match PORT in intern-task-app's Dockerfile (8080)."
  type        = number
  default     = 8080
}
