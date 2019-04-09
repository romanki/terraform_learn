resource "aws_security_group" "lb" {
  name        = "${var.environment}_${var.service}_alb"
  description = "Allow access ${var.environment} alb(s)"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    ignore_changes = [
      "description",
      "ami"]
  }

  tags = "${local.tags}"
}

resource "aws_security_group_rule" "lb_ingress" {
  security_group_id = "${aws_security_group.lb.id}"

  from_port = 0
  to_port   = 0
  protocol  = "-1"
  type      = "ingress"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_egress" {
  security_group_id = "${aws_security_group.lb.id}"

  from_port = 0
  to_port   = 0
  protocol  = "-1"
  type      = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}
