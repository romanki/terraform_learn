output "ssl_arn" {
  value = "${aws_acm_certificate.cert.arn}"
}

output "zone_id" {
  value = "${aws_route53_zone.zone.zone_id}"
}

output "private_zone_id" {
  value = "${local.private_zone_id}"
}
