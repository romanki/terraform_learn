resource "aws_lb" "lb" {
  name               = "${var.environment}-${var.service}"
  load_balancer_type = "application"
  internal           = false

  security_groups = ["${aws_security_group.lb.id}", ]
  enable_cross_zone_load_balancing = "${var.cross_zone_load_balancing}"

  subnets = [ "${var.subnet_ids}" ]

  tags = "${local.tags}"
}
