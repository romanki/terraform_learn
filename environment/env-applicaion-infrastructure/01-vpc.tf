module "vpc" {
  source = "../../modules/mod-vpc"

  name = "${var.environment}"

  cidr = "${var.vpc_cidr}"

  azs  = "${var.vpc_azs}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames   = "${var.vpc_enable_dns_hostnames}"
  one_nat_gateway_per_az = "${var.vpc_one_nat_gateway_per_az}"

  public_subnet_tags = {
    Name = "product-ecs-subnet-public"
    scope = "public"
  }

  public_route_table_tags = {
    Name = "product-ecs-rt-public"
    scope = "public"
  }

  private_subnet_tags = {
    Name = "product-ecs-subnet-private"
    scope = "private"
  }

  private_route_table_tags = {
    Name = "product-ecs-rt-private"
    scope = "private"
  }

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
  }
  vpc_tags = {
    Name  = "product_ecs_vpc"
    Owner = "${var.owner}"
  }
}


data "aws_vpc" "default" {
  tags = {
    Environment = "${var.environment}"
    service = "default"
  }
}

data "aws_route_table" "default_public" {
  vpc_id = "${data.aws_vpc.default.id}"
  tags = {
    scope = "public"
  }
}

data "aws_route_table" "default_private" {
  vpc_id = "${data.aws_vpc.default.id}"
  tags = {
    scope = "private"
  }
}


module "vpc-peering" {
  source = "../../modules/mod-vpc-peer"

  vpc_1_name = "default"
  vpc_1_id = "${data.aws_vpc.default.id}"
  vpc_1_public_route_table_id = "${data.aws_route_table.default_public.id}"
  vpc_1_private_route_table_id = "${data.aws_route_table.default_private.id}"
  vpc_1_cidr = "${data.aws_vpc.default.cidr_block}"

  vpc_2_name = "product-ecs"
  vpc_2_id = "${module.vpc.vpc_id}"
  vpc_2_public_route_table_id = "${module.vpc.public_route_table_ids[0]}"
  vpc_2_private_route_table_id = "${module.vpc.private_route_table_ids[0]}"
  vpc_2_cidr = "${module.vpc.vpc_cidr_block}"
}
