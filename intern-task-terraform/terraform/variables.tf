
variable "aws_region" {
  description = "AWS region for the planned infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Plausible Ubuntu AMI ID for us-east-1."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "CIDR allowed to access SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "Provide a valid SSH CIDR, such as 203.0.113.10/32."
  }
}

