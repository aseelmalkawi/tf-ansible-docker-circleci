terraform {
  backend "s3" {
    bucket         = "terraform-state-hmada-lul"
    key            = "terraformStat/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state_lock"
  }
}