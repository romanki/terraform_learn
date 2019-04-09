resource "aws_db_subnet_group" "default" {
  name       = "${lower("${var.environment}-${var.service}-${var.rds_cluster_enabled ? "RDSClusterSubnetGroup" : "RDSInstanceSubnetGroup"}")}"
  subnet_ids = [ "${var.rds_subnets}" ]

  tags = "${local.tags}"
}

resource "aws_rds_cluster" "main" {
  count = "${var.rds_cluster_enabled}"

  cluster_identifier  = "${lower("${var.environment}-${var.service}-RDSCluster-${count.index+1}")}"
  engine              = "aurora-postgresql"
  database_name       = "${var.db_name}"
  master_username     = "${var.rds_master_username}"
  master_password     = "${local.master_password}"
  apply_immediately   = "true" # enabled to ensure password rotations are immediate

  vpc_security_group_ids = ["${aws_security_group.rds.id}"]

  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  backup_retention_period   = "${var.rds_backup_retention_period}"
  final_snapshot_identifier = "${var.environment}-final-rds-snapshot"
  availability_zones        = [ "${var.rds_azs}" ]

  tags = "${local.tags}"
}

resource "aws_rds_cluster_instance" "main_instances" {
  count = "${var.rds_cluster_enabled ? var.rds_instance_count : 0}"

  identifier         = "${aws_rds_cluster.main.cluster_identifier}-${count.index+1}"
  cluster_identifier = "${aws_rds_cluster.main.id}"
  instance_class     = "${var.rds_instance_cluster_class}"

  db_subnet_group_name    = "${aws_db_subnet_group.default.name}"
  db_parameter_group_name = "${aws_db_parameter_group.pg.name}"

  engine         = "${aws_rds_cluster.main.engine}"
  engine_version = "${aws_rds_cluster.main.engine_version}"

  tags = "${local.tags}"
}

#Single instance without cluster
resource "aws_db_instance" "instances" {
  count = "${1 - var.rds_cluster_enabled}"
  allocated_storage = "${var.rds_allocated_storage}"

  engine               = "postgres"
  engine_version       = "${var.instance_engine_version}"
  identifier           = "${lower("${var.environment}-${var.service}-RDSInstance-${count.index+1}")}"
  instance_class       = "${var.rds_instance_class}"
  parameter_group_name = "${aws_db_parameter_group.pg.name}"

  username = "${var.rds_master_username}"
  password = "${local.master_password}"
  name     = "${var.db_name}"

  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  skip_final_snapshot    = "${var.skip_final_snapshot}"

  tags = "${local.tags}"
}

resource "random_string" "rds_password" {
  length           = "${var.rds_password_length}"
  special          = true
  override_special = "<>!#%&()=?"
}

locals {
  # allow var.rds_master_password to overrule
  master_password = "${var.rds_master_password == "" ? random_string.rds_password.result : var.rds_master_password}"
  db_host_module = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.endpoint) : join("", aws_db_instance.instances.*.address)}"

  database_details = {
    db_engine         = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.engine)          : join("", aws_db_instance.instances.*.engine)}"
    db_engine_version = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.engine_version)  : join("", aws_db_instance.instances.*.engine_version)}"
    db_username       = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.master_username) : join("", aws_db_instance.instances.*.username)}"
    db_password       = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.master_password) : local.master_password}"
    db_host           = "${length(var.rds_dns_name) > 0 ? var.rds_dns_name : local.db_host_module}"
    db_read_host      = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.reader_endpoint) : join("", aws_db_instance.instances.*.address)}"
    db_port           = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.port)            : join("", aws_db_instance.instances.*.port)}"
    db_instance_type  = "${var.rds_cluster_enabled ? join("", aws_rds_cluster_instance.main_instances.*.instance_class) : join("", aws_db_instance.instances.*.instance_class)}"
  }
}
