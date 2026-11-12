variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Specific IPv4 CIDR allowed to access SSH."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid IPv4 CIDR block, such as 203.0.113.10/32."
  }
}

variable "app_port" {
  description = "Port exposed by the intern-task-app container."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}
