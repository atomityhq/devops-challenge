variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to connect to the instance over SSH."
  type        = string
}

variable "app_port" {
  description = "Port on which the application listens."
  type        = number
  default     = 8080
}
