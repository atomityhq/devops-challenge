
variable "aws_region" {
  description = "AWS region used for the infrastructure plan."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for resource names and tags."
  type        = string
  default     = "intern-task"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "ssh_allowed_cidr" {
  description = "Single trusted IPv4 CIDR allowed to access SSH."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.ssh_allowed_cidr)) &&
      endswith(var.ssh_allowed_cidr, "/32")
    )
    error_message = "Provide one trusted IPv4 address in /32 CIDR format."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI for the selected AWS region."
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "app_port" {
  description = "Port exposed by the Challenge 1 application."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port == 8080
    error_message = "This implementation uses the Challenge 1 application port 8080."
  }
}

