resource "aws_route53_zone" "zone" {
  name = "${var.hosted_zone}"

  tags = "${local.tags}"
}

resource "aws_route53_zone" "private" {
  count = "${var.private_zone}"
  name  = "${local.private_hosted_zone}"

  vpc {
    vpc_id = "${var.vpc_id}"
  }
}

locals {
  private_zone_id = "${var.private_zone ? join("", aws_route53_zone.private.*.id) : ""}"
}
