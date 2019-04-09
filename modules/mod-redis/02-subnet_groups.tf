resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.owner}-${var.env}-${var.platform}-${var.service}"
  subnet_ids = ["${element(var.subnets_redis, count.index)}"]
}
