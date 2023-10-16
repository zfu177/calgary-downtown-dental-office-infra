data "aws_availability_zones" "default" {
  all_availability_zones = true
  filter {
    name   = "region-name"
    values = [var.region]
  }
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = slice(data.aws_availability_zones.default.names, 0, 2)
  public_subnets   = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  private_subnets  = [cidrsubnet(var.vpc_cidr, 8, 16), cidrsubnet(var.vpc_cidr, 8, 17)]
  database_subnets = [cidrsubnet(var.vpc_cidr, 8, 32), cidrsubnet(var.vpc_cidr, 8, 33)]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  create_database_nat_gateway_route      = false

  tags = var.additional_tags
}
