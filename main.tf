terraform {
  required_version = ">=0.12"
  backend "s3" {
    bucket = "app-buck"
    key    = "app/terraform.tfstate"
    region = "eu-west-3"
  }
}
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app-vpc"
  cidr = var.vpc_cidr_block

  azs            = [var.avail_zone]
  public_subnets = [var.subnet_cidr_block]

  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet_1"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}
module "app_server" {
  source              = "./modules/webserver"
  vpc_id              = module.vpc.vpc_id
  my_ip               = var.my_ip
  env_prefix          = var.env_prefix
  image_name          = var.image_name
  public_key_location = var.public_key_location
  subnet_id           = module.vpc.public_subnets[0]
  avail_zone          = var.avail_zone
  instance_type       = var.instance_type
}
