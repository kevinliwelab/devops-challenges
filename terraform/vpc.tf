locals {
  name   = "devops-challenge"
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "172.20.0.0/16"

  azs               = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets   = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]
  public_subnets    = ["172.20.11.0/24", "172.20.12.0/24", "172.20.13.0/24"]
  database_subnets  = ["172.20.21.0/24", "172.20.22.0/24", "172.20.23.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true # as it is demo, using single NAT to save $
  one_nat_gateway_per_az  = false
}
