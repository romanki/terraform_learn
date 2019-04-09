#data "aws_route53_zone" "zone" {
#  name = "${lower(var.environment)}.${lower(var.domain)}"
#}
#
#resource "aws_route53_record" "lb" {
#  zone_id = "${data.aws_route53_zone.zone.zone_id}"
#  name = "nlb.${data.aws_route53_zone.zone.name}"
#  type = "A"
#
#  alias {
#    name                   = "${aws_lb.lb.dns_name}"
#    zone_id                = "${aws_lb.lb.zone_id}"
#    evaluate_target_health = true
#  }
#}
