variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID."
  type        = string
  default     = "ami-0c101f26f147fa7fd"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Administrator public IP address in CIDR notation."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "Provide a valid IPv4 CIDR, for example 203.0.113.10/32."
  }
}

variable "key_name" {
  description = "Optional existing EC2 key pair name."
  type        = string
  default     = null
}
