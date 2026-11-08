variable "aws_region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Prefix used for resource names."
  type        = string
  default     = "intern-task-terraform"
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

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Single CIDR range allowed to connect over SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "ssh_cidr must be a valid IPv4 CIDR block, such as 203.0.113.10/32."
  }
}

variable "app_port" {
  description = "Port the app listens on, taken from the app Dockerfile."
  type        = number
  default     = 5000
}

variable "linux_user" {
  description = "Non-root Linux account created by user data."
  type        = string
  default     = "appuser"
}
