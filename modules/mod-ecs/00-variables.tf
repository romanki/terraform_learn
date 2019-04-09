variable "project"        {default = "Unknown"}
variable "environment"    {default = "Unknown" }
variable "cluster_name"   {default = "Default"}
variable "service"        {default = ""}
variable "owner"          {default = ""}

variable "expiration_date" {default = ""}
variable "cost_center"     {default = ""}
variable "tags"            {type = "map" default = {}}
variable "foxpass_sm"      {default = ""}

variable "vpc_id" {}
variable "ami_id"            {default = "ami-6944c513"}
variable "ami_owners"        {type="list" default = ["self", "amazon", "aws-marketplace"]}
variable "lookup_latest_ami" {default=false}

variable "root_block_device_type" {default = "gp2" }
variable "root_block_device_size" {default = "8"}

variable "instance_type"        {default = "t2.micro"}
variable "key_name"             {}
variable "cloud_config_content" {}
variable "cloud_config_content_type" {default = "text/cloud-config"}

variable "health_check_grace_period" {default = "600"}
variable "desired_capacity" {default = "1"}

variable "min_size" {default = "1"}
variable "max_size" {default = "1"}

variable "private_subnet_ids"          {type = "list"}
variable "scale_up_cooldown_seconds"   {default = "300"}
variable "scale_down_cooldown_seconds" {default = "300"}
variable "high_cpu_evaluation_periods" {default = "2"}
variable "high_cpu_period_seconds"     {default = "300"}
variable "high_cpu_threshold_percent"  {default = "90"}
variable "low_cpu_evaluation_periods"  {default = "2"}
variable "low_cpu_period_seconds"      {default = "300"}
variable "low_cpu_threshold_percent"   {default = "10"}

variable "high_memory_evaluation_periods" {default = "2"}
variable "high_memory_period_seconds"     {default = "300"}
variable "high_memory_threshold_percent"  {default = "90"}
variable "low_memory_evaluation_periods"  {default = "2"}
variable "low_memory_period_seconds"      {default = "300"}
variable "low_memory_threshold_percent"   {default = "10"}
variable "low_slots_evaluation_periods"   {default = "2"}
variable "low_slots_period_seconds"       {default = "30"}
variable "low_slots_threshold"            {default = "1"}

variable "efs_mount_point" {default = "/efs"}

variable "userdata_ecs_agent"      { default = false }
variable "userdata_nvidia_drivers" { default = false }

locals {
  local_tags = {
    Environment    = "${var.environment}"
    ManagedBy      = "terraform"
    Project        = "${var.project}"
    Service        = "${var.service}"
    Owner          = "${var.owner}"
    ExpirationDate = "${var.expiration_date}"
    CostCenter     = "${var.cost_center}"
  }

  foxpass_sm       = "${var.foxpass_sm}"
  foxpass_bind_pwd = "${lookup(data.external.foxpass_secrets.result, "bind_pw", "")}"
  foxpass_api_key  = "${lookup(data.external.foxpass_secrets.result, "api_key", "")}"
  tags             = "${merge(local.local_tags, var.tags)}"
}

data "aws_secretsmanager_secret_version" "foxpass_secrets" {
  secret_id = "${local.foxpass_sm}"
}

data "external" "foxpass_secrets" {
  program = [ "echo", "${data.aws_secretsmanager_secret_version.foxpass_secrets.secret_string}" ]
}

variable "latest_ami_name" { default = "amzn-ami-*-amazon-ecs-optimized" }
