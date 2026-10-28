terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Lets `terraform plan` run against fake credentials without calling AWS.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

}