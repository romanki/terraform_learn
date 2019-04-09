resource "aws_db_parameter_group" "pg" {
  name   = "${lower("${var.environment}-${var.service}-${var.rds_cluster_enabled ? "rds-cluster" : "rds-instance"}")}"
  family = "${var.rds_cluster_enabled ? "aurora-postgresql9.6" : "postgres9.6"}"

  parameter {
    name = "log_statement"
    value = "all"
    apply_method = "immediate"
  }

  tags = "${local.tags}"
}
