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
