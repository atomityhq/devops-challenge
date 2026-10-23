variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI for the instance (Ubuntu)"
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port intern-task-app listens on (set in its Dockerfile)"
  type        = number
  default     = 8080
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH to the instance, e.g. your IP as x.x.x.x/32"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "admin_user" {
  description = "Non-root user created on the instance"
  type        = string
  default     = "deploy"
}
