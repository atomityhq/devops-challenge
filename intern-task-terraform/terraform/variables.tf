variable "aws_region" {
  description = "AWS region in which to describe the resources."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Specific CIDR range allowed to connect over SSH."
  type        = string

  validation {
    condition     = var.ssh_cidr != "0.0.0.0/0"
    error_message = "SSH must not be open to the entire internet."
  }
}

variable "app_port" {
  description = "Port on which intern-task-app listens."
  type        = number
  default     = 8080
}
