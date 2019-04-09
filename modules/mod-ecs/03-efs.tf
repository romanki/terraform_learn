resource "aws_efs_file_system" "efs" {
  tags = "${local.tags}"
}

#resource "aws_efs_mount_target" "ecs_efs" {
#  count = "${length(var.private_subnet_ids)}"
#  security_groups = ["${aws_security_group.efs.id}"]
#  file_system_id  = "${aws_efs_file_system.efs.id}"
#  subnet_id       = "${element(var.private_subnet_ids, count.index)}"
#}

resource "aws_efs_mount_target" "ecs_efs_0" {
  depends_on = ["aws_security_group.efs"]
  security_groups = ["${aws_security_group.efs.id}"]
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(var.private_subnet_ids, 0)}"
}

resource "aws_efs_mount_target" "ecs_efs_1" {
  depends_on = ["aws_security_group.efs"]
  security_groups = ["${aws_security_group.efs.id}"]
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(var.private_subnet_ids, 1)}"
}

resource "aws_efs_mount_target" "ecs_efs_2" {
  depends_on = ["aws_security_group.efs"]
  security_groups = ["${aws_security_group.efs.id}"]
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(var.private_subnet_ids, 2)}"
}

resource "aws_security_group" "efs" {
  name        = "${var.cluster_name}_${var.environment}_efs"
  description = "Allow access to ${var.cluster_name}_${var.environment} EFS"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    ignore_changes = ["description"]
  }

  tags = "${local.tags}"
}

resource "aws_security_group_rule" "efs_ingress" {
  security_group_id = "${aws_security_group.efs.id}"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  type              = "ingress"

  source_security_group_id = "${aws_security_group.container_instance.id}"
}

resource "aws_security_group_rule" "web_efs_egress" {
  security_group_id = "${aws_security_group.efs.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
