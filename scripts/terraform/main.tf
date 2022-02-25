# vim: foldmethod=indent et ts=2 sw=2:
# terraform {
#   backend "s3" {
#     bucket = "openreplay-inst-test-state"
#     key = "terraform"
#   }
# }
provider "aws" { }

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "openreplay-vpc-${var.environment}"
  cidr = var.cidr

  azs = data.aws_availability_zones.available.names

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

module "database" {
  source = "./components/postgres"
  database_user_password = var.database_user_password
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  database_subnet_group = module.vpc.database_subnet_group
}

output "test" {
  value = module.vpc.vpc_id
}
