terraform {
  # CI pins Terraform 1.12.0, so this range must admit it. The upper bound
  # stops a future major version from silently changing plan behaviour.
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  # These three make `terraform plan` a pure calculation: no STS call, no
  # account-id lookup, no region check. Without them plan needs real
  # credentials, and this module is never applied anywhere.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}
