variable "aws_region" {
  description = "AWS region in which to define the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "ssh_cidr" {
  description = "CIDR range permitted to connect to the instance over SSH, e.g. your-public-IP/32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid IPv4 CIDR range, such as 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Linux AMI ID valid for the selected AWS region."
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "app_port" {
  description = "Port used by the application in the Docker container."
  type        = number
  default     = 5000

  validation {
    condition     = var.app_port == 5000
    error_message = "The application must use port 5000."
  }
}