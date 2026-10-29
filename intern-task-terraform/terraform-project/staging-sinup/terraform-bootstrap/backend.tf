######################################################
#################### Terrafrom Backend s3 ############
######################################################
terraform {
  backend "s3" {
    bucket       = "internal-terraform-state-2026"
    key          = "stage/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
