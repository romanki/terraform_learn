output "lb_arn" {
  value = "${data.aws_lb.lb.arn}"
}

output "lb_dns_name" {
  value = "${data.aws_lb.lb.dns_name}"
}

output "lb_port" {
  value = "${var.lb_port}"
}

output "lb_target_group_arn" {
  value = "${aws_lb_target_group.tg.arn}"
}
