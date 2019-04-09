resource "aws_route53_record" "dns_record" {
  count = "${length(var.dns_records)}"

  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "${element(var.dns_records, count.index)}"
  type    = "A"

  alias {
    name                   = "${var.alb_dns_name}"
    zone_id                = "${var.alb_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "private_cname_records" {
  count =  "${var.private_dns_records_count}"

  zone_id = "${aws_route53_zone.private.zone_id}"

  name = "${element(keys(var.private_cname_records), count.index)}"
  type = "CNAME"
  ttl = "60"

  records = ["${element(values(var.private_cname_records), count.index)}"]
}
