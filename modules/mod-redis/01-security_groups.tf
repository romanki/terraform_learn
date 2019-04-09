resource "aws_security_group" "redis" {
  name        = "${var.owner}_${var.env}_${var.platform}_${var.service}"
  description = "Allow access to ${var.owner}-${var.env}-${var.platform} Redis instance(s)"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.owner}_${var.env}_${var.platform}_${var.service}"
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Platform    = "${var.platform}"
  }
}

resource "aws_security_group_rule" "redis_ingress" {
  security_group_id = "${aws_security_group.redis.id}"

  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  type              = "ingress"

  source_security_group_id = "${var.inbound_sg_ecs}"
}

resource "aws_security_group_rule" "redis_egress" {
  security_group_id = "${aws_security_group.redis.id}"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}
