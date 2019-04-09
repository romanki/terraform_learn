variable "environment"                {}
variable "project"                    {}
variable "service"                    {}
variable "owner"                      {}

variable "rds_azs"     { type = "list" }
variable "rds_subnets" { type = "list" }

variable "secret_name" { default = "" }

variable "rds_backup_retention_period" { default = "30" }
variable "rds_master_username"         { default = "root" }
variable "rds_master_password"         { default = "" }
variable "rds_instance_count"          { default = "1" }
variable "rds_instance_cluster_class"  { default = "db.r4.large" }
variable "rds_password_length"         { default = "16" }
variable "rds_allocated_storage"       { default = 16 }
variable "rds_default_db" { default = "initial" }

variable "snapshot_identifier"         { default = "" }

variable "skip_final_snapshot" { default = false }

variable "cloudwatch_log_lambda_name"  { default = "" }

variable "rds_cluster_enabled" { default = true }
variable "db_name"             { default = "initial" }

variable "tags" {
  type = "map"
  default = {}
}

variable "rds_dns_name" { default = "" }

locals {
  local_tags = {
    Environment    = "${var.environment}"
    Project        = "${var.project}"
    Service        = "${var.service}"
    Owner          = "${var.owner}"
    ManagedBy      = "terraform"
  }

  tags = "${merge(local.local_tags, var.tags)}"
}

variable "vpc_id"         {}
variable "inbound_sg_ecs" { default = "" }
variable "inbound_sg_vpn" { default = "" }

variable "rds_instance_class"      { default = "db.t2.small" }
variable "empty_list"              { type = "list" default = [] }
variable "instance_engine_version" { default = "9.6.11" }
