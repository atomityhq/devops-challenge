variable "region" {
  description = "AWS region for the instance"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Prefix for resource names and tags"
  type        = string
  default     = "intern-task-app"
}

variable "ami_id" {
  description = "AMI to launch (Ubuntu 22.04 in us-east-1). Placeholder; never launched in this challenge."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name for the default ubuntu user"
  type        = string
  default     = null
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

variable "app_port" {
  description = "Port the app listens on. Must match PORT / EXPOSE in intern-task-app/Dockerfile."
  type        = number
  default     = 5000
}

variable "ssh_cidr" {
  description = "The only CIDR allowed to SSH in, for example 203.0.113.10/32. Deliberately has no default."
  type        = string
}
