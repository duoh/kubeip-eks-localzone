provider "aws" {
  region = var.region
}

locals {
  region = var.region

  azs          = ["${local.region}a", "${local.region}b", "${local.region}c"]
  lzs          = var.lzs
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.name
  cidr            = var.vpc_cidr
  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw         = true

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_subnet" "public-subnet-lz" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 5)
  availability_zone       = local.lzs[0]
  map_public_ip_on_launch = true
  tags = merge(
    { "Name" = "${module.vpc.name}-public-${local.lzs[0]}" },
  )
}

resource "aws_subnet" "private-subnet-lz" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10 + 5)
  availability_zone = local.lzs[0]
  tags = merge(
    { "Name" = "${module.vpc.name}-private-${local.lzs[0]}" },
  )
}

resource "aws_route_table_association" "public-subnet-lz-rta" {
  subnet_id      = aws_subnet.public-subnet-lz.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

resource "aws_route_table_association" "private-subnet-lz-rta" {
  subnet_id      = aws_subnet.private-subnet-lz.id
  route_table_id = module.vpc.private_route_table_ids[0]
}

