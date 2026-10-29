variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR block for the public subnet"
  type        = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.50.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  default = [
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "availability_zone" {
  description = "Availability zone for subnet placement"
  type        = string
  default     = "us-east-1a"
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}