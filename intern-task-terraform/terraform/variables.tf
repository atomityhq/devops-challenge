variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "app_port" {
  description = "Port the application listens on."
  type        = number
  default     = 5000
}

variable "ssh_cidr" {
  description = "CIDR allowed to connect through SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "Provide a valid CIDR, such as 203.0.113.10/32."
  }
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
