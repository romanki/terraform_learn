output "sg_redis"   {
  value = "${aws_security_group.redis.id}"
}

output "redis_details" {
  value     = "${local.redis_details}"
  sensitive = true
}
