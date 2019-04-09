# Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id               = "${var.cluster_redis_name}"
  engine                   = "redis"
  engine_version           = "3.2.6"
  node_type                = "${var.cluster_redis_node_type}"
  port                     = "6379"
  num_cache_nodes          = "${var.cluster_redis_node_num}"
  parameter_group_name     = "${aws_elasticache_parameter_group.redis.id}"
  subnet_group_name        = "${aws_elasticache_subnet_group.redis.name}"
  security_group_ids       = ["${aws_security_group.redis.id}", ]
  apply_immediately        = true
  maintenance_window       = "Mon:03:00-Mon:04:00"
  snapshot_retention_limit = "0"
  //availability_zone        = "${var.azs}"

  tags {
    Name        = "${var.owner}_${var.env}_${var.platform}_${var.service}"
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Platform    = "${var.platform}"
  }
}

locals {
  # allow var.rds_master_password to overrule
  redis_details = {
    redis_endpoint = "${aws_elasticache_cluster.redis.cache_nodes.0.address}"
    redis_port     = "${aws_elasticache_cluster.redis.port}"
  }
}
