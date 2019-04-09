module "r53" {
  source = "../../modules/mod-r53"

  environment       = "${var.environment}"
  owner             = "${var.owner}"
  project           = "${var.owner}"

  hosted_zone     = "${var.hosted_zone}"
  sll_certificate = "${var.ssl_certificate}"

  dns_records  = "${var.dns_records}"
  alb_zone_id  = "${local.alb_zone_id}"
  alb_dns_name = "${local.alb_dns_name}"

  private_zone          = "${var.r53_private_zone}"
  vpc_id                =  "${module.vpc.vpc_id}"
  private_cname_records = "${local.private_dns_records}"

  private_dns_records_count = "${local.private_dns_records_count}"
}
