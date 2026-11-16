variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI. Never launched in this task, so any plausible value is fine."
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "app_port" {
  description = "Port the app listens on. Must match ENV PORT / EXPOSE in intern-task-app/Dockerfile."
  type        = number
  default     = 5000
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH in, e.g. 203.0.113.10/32. No default on purpose."
  type        = string
}

variable "repo_url" {
  description = "Public Git repo that contains intern-task-app/"
  type        = string
  default = "https://github.com/manal333/devops-challenge.git"
}

variable "repo_ref" {
  description = "Branch or tag to clone"
  type        = string
  default     = "main"
}
