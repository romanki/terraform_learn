# output the standard outputs of aws_rds_cluster
output "id"                            { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.id)                           : join("", aws_db_instance.instances.*.id)}" }
//output "cluster_members"               { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.cluster_members)    : ""}" }
//output "availability_zones"            { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.availability_zones) : join("", aws_db_instance.instances.*.availability_zone)}" }
output "backup_retention_period"       { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.backup_retention_period)      : join("", aws_db_instance.instances.*.backup_retention_period)}" }
output "preferred_maintenance_window"  { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.preferred_maintenance_window) : join("", aws_db_instance.instances.*.maintenance_window) }" }
output "endpoint"                      { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.endpoint)                     : join("", aws_db_instance.instances.*.address) }" }
output "reader_endpoint"               { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.reader_endpoint)              : join("", aws_db_instance.instances.*.address) }" }
output "engine"                        { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.engine)                       : join("", aws_db_instance.instances.*.engine) }" }
output "engine_version"                { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.engine_version)               : join("", aws_db_instance.instances.*.engine_version) }" }
output "database_name"                 { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.database_name)                : join("", aws_db_instance.instances.*.name) }" }
output "port"                          { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.port)                         : join("", aws_db_instance.instances.*.port) }" }
output "master_username"               { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.master_username)              : join("", aws_db_instance.instances.*.username) }" }
output "hosted_zone_id"                { value = "${var.rds_cluster_enabled ? join("", aws_rds_cluster.main.*.hosted_zone_id)               : join("", aws_db_instance.instances.*.hosted_zone_id) }" }

# provide the master_password that was used and mark as sensitive
output "rds_master_password" {
  value     = "${aws_rds_cluster.main.*.master_password}"
  sensitive = true
}

# output the database details for the time being to be written outside the module
output "database_details" {
  value     = "${local.database_details}"
  sensitive = true
}

output "rds_security_group_id" { value = "${aws_security_group.rds.id}" }
