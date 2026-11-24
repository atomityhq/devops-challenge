
variable "ami_id" {
  description = "AMI used to launch the EC2 instance"
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "ssh_cidr" {
  description = "IPv4 CIDR to access ssh"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid IPv4 CIDR."
  }
}

variable "repository_url" {
  description = "GitHub repository containing intern-task-app"
  type        = string
  default     = "https://github.com/HarunHudaiTan/devops-challenge.git"
}

variable "repository_branch" {
  description = "Git branch containing the completed application"
  type        = string
  default     = "feat/devops-challenge"
}
