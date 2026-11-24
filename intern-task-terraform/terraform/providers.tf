provider "aws" {
  region = var.aws_region

  # Lets `terraform plan` run against fake credentials without calling AWS.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}
