variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "ap-southeast-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0403d346e3210afd6"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to access the instance through SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && can(cidrnetmask(var.ssh_allowed_cidr))
    error_message = "Provide a valid CIDR block, such as your public IP followed by /32."
  }
}

variable "app_port" {
  description = "Port used by the intern-task-app container."
  type        = number
  default     = 5000

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535 && floor(var.app_port) == var.app_port
    error_message = "The application port must be an integer between 1 and 65535."
  }
}
