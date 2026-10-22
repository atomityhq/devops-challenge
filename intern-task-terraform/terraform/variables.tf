
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for the selected region"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access SSH, for example 203.0.113.10/32"
  type        = string
  nullable    = false

  validation {
    condition = (
      can(cidrnetmask(var.ssh_allowed_cidr)) &&
      can(regex("/([1-9]|[12][0-9]|3[0-2])$", var.ssh_allowed_cidr))
    )

    error_message = "Provide a valid IPv4 CIDR with a prefix length between /1 and /32. SSH access from 0.0.0.0/0 is not allowed."
  }
}

variable "app_port" {
  description = "Port exposed by the application Docker image"
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "The application port must be between 1 and 65535."
  }
}
