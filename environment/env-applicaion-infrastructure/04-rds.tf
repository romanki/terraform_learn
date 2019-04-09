module "rds" {
  source = "../../modules/mod-rds"

  rds_azs     = [ "${var.vpc_azs}" ]
  rds_subnets = [ "${module.vpc.private_subnets}" ]

# this triggers a bug in terraform that results in a module.rds.aws_secretsmanager_secret_version.rds_details: aws_secretsmanager_secret_version.rds_details: value of 'count' cannot be computed error
# currently writing of secrets is done outside of the module
# secret_name = "${data.aws_secretsmanager_secret.rds_secret.arn}"

  environment       = "${var.environment}"
  service           = "${var.service}"
  owner             = "${var.owner}"
  project           = "${var.owner}"

  vpc_id         = "${module.vpc.vpc_id}"
  inbound_sg_ecs = "${module.ecs.container_instance_security_group_id}"
  inbound_sg_vpn = "${local.vpn_sg}"

  rds_dns_name = "${local.rds_dns_name}"

  tags = "${local.tags}"
  rds_cluster_enabled = false
}

resource "aws_secretsmanager_secret_version" "rds_details" {
  secret_id     = "${lower("rds/main")}"
  secret_string = "${jsonencode(module.rds.database_details)}"
}
