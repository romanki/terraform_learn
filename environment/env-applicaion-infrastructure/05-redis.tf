module "redis" {
  source = "../../modules/mod-redis"

  owner    = "${var.owner}"
  env      = "${var.environment}"
  platform = "${var.account_prefix}"
  service  = "redis"

  region = "${var.aws_region}"
  azs    = "${var.vpc_azs}"

  vpc_id   = "${module.vpc.vpc_id}"
  vpc_cidr = "${var.vpc_cidr}"

  inbound_sg_ecs = "${module.ecs.container_instance_security_group_id}"

  subnets_redis = "${module.vpc.private_subnets}"
  subnet_redis_route_table = "${module.vpc.default_route_table_id}"

  cluster_redis_node_num  = 1
  cluster_redis_node_type = "cache.t2.micro"
  cluster_redis_name      = "${var.environment}-redis"
}

resource "aws_secretsmanager_secret_version" "redis_details" {
  secret_id     = "${lower("redis/main")}"
  secret_string = "${jsonencode(module.redis.redis_details)}"
}
