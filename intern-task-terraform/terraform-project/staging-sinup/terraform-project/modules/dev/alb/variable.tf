variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "application_port" {
  type = number
}

variable "target_instance_id" {
  type = string
}

variable "health_check_path" {
  type    = string
  default = "/"
}