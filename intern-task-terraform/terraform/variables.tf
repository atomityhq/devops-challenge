
variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string

  validation {
    condition = can(cidrnetmask(var.ssh_cidr)) && (
      tonumber(split("/", var.ssh_cidr)[1]) >= 0 &&
      tonumber(split("/", var.ssh_cidr)[1]) <= 32
    )
    error_message = "ssh_cidr must be a valid IPv4 CIDR block."
  }
}
