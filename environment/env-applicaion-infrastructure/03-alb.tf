module "product_alb" {
  source = "../../modules/mod-alb"

  environment = "${var.environment}"
  project     = "${var.owner}"
  service     = "${var.service}"
  owner       = "${var.owner}"
  vpc_id      = "${module.vpc.vpc_id}"

  subnet_ids = [ "${module.vpc.public_subnets}" ]
}

module "product_alb_internal" {
  source = "../../modules/mod-alb"

  environment = "${var.environment}"
  project     = "${var.owner}"
  service     = "${var.service}-internal"
  owner       = "${var.owner}"
  vpc_id      = "${module.vpc.vpc_id}"

  subnet_ids = [ "${module.vpc.public_subnets}" ]
}
