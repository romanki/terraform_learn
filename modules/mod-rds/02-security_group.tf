resource "aws_security_group" "rds" {
  name        = "${var.environment}-${var.service}_${var.rds_cluster_enabled ? "rds" : "rds_instance"}"
  description = "Allow access ${var.environment} rds(s)"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    ignore_changes = [
      "description",
      "ami"]
  }

  tags = "${local.tags}"
}

resource "aws_security_group_rule" "inbound_ecs" {

  security_group_id = "${aws_security_group.rds.id}"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  type              = "ingress"

  source_security_group_id = "${var.inbound_sg_ecs}"
}

resource "aws_security_group_rule" "inbound_vpn" {

  security_group_id = "${aws_security_group.rds.id}"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  type              = "ingress"

  source_security_group_id = "${var.inbound_sg_vpn}"
}

resource "aws_security_group_rule" "rds_egress" {
  security_group_id = "${aws_security_group.rds.id}"

  from_port = 0
  to_port   = 0
  protocol  = "-1"
  type      = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}
