variable "aws_region" {
  description = "AWS Region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI ID for us-east-1"
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Specific IPv4 CIDR allowed to access SSH"
  type        = string

  validation {
    condition = (
      can(cidrhost(var.ssh_cidr, 0)) &&
      var.ssh_cidr != "0.0.0.0/0"
    )
    error_message = "Provide a valid, restricted SSH CIDR. SSH cannot be open to the world."
  }
}

variable "app_port" {
  description = "Port used by the intern-task-app container"
  type        = number
  default     = 5000

  validation {
    condition     = var.app_port == 5000
    error_message = "The application port must match the Task 1 Dockerfile: 5000."
  }
}