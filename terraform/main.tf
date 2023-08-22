# AWS
provider "aws" {
  region = "us-east-1"
}

module "network" {
  source                  = "./network"

  vpc_name                = var.vpc_name
  vpc_cider               = var.vpc_cider

  public_subnet           = var.public_subnet 
  public_subnet_1a_cider  = var.public_subnet_1a_cider

  private_subnet          = var.private_subnet
  private_subnet_1b_cider = var.private_subnet_1b_cider

  availability_zone_1a    = var.availability_zone_1a
  availability_zone_1b    = var.availability_zone_1b

  workspace               = var.workspace
}