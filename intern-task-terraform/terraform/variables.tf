variable "aws_region" {
  description = "AWS region used for the planned infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID for us-east-1."
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to connect to the instance over SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR block."
  }
}
