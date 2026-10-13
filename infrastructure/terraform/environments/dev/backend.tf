terraform {
  backend "s3" {
    bucket       = "shopsphere-terraform-state-dd397ea6"
    key          = "shopsphere/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
