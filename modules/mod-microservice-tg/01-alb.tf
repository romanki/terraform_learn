data "aws_lb" "lb" {
  arn = "${var.lb_arn}"
}

data "aws_subnet" "sn" {
  id = "${element(data.aws_lb.lb.subnets, 0)}"
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.environment}-${var.service}-TG"
  port        = "${var.target_port}"
  protocol    = "HTTP"
  vpc_id      = "${data.aws_subnet.sn.vpc_id}"

  deregistration_delay = "30"

  target_type = "instance"

  tags = "${local.tags}"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    interval            = "30"
    path                = "${var.target_healthcheck}"
    protocol            = "HTTP"
    timeout             = "10"
    healthy_threshold   = "2"
    unhealthy_threshold = "5"
    matcher             = "${var.tg_healthcheck_matcher}"
  }
}

resource "aws_lb_listener" "listener_https" {
  count = "${var.protocol == "HTTPS" ? 1 : 0}"
  load_balancer_arn = "${data.aws_lb.lb.arn}"
  port              = "${var.lb_port}"
  protocol          = "${var.protocol}"
  certificate_arn   = "${var.ssl_arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "listener" {
  count = "${var.protocol == "HTTP" ? 1 : 0}"
  load_balancer_arn = "${data.aws_lb.lb.arn}"
  port              = "${var.lb_port}"
  protocol          = "${var.protocol}"

  default_action {
    target_group_arn = "${aws_lb_target_group.tg.arn}"
    type             = "forward"
  }
}
