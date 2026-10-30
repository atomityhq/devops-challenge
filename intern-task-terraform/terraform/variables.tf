variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux EC2 AMI ID"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Allowed SSH source CIDR"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "Provide a valid CIDR."
  }
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}

variable "git_repo_url" {
  description = "Public GitHub fork URL"
  type        = string
}

variable "git_branch" {
  description = "Application source branch"
  type        = string
  default     = "solution/anjan-prajapati"
}
