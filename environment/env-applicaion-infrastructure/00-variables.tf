variable "environment"       { default = "" }
variable "environment_short" { default = "" }
variable "owner"             { default = "learn" }
variable "account_prefix"    { default = "" }
variable "aws_region"        { default = "us-east-1" }
variable "aws_secrets_env"   { type    = "list" default = [] }
variable "service"           { default = "" }

variable "vpc_azs"  { type = "list" default = [] }
variable "vpc_cidr" {}

variable "private_subnets" { type = "list" default = [] }
variable "private_ips"     { type = "list" default = [] }
variable "public_subnets"  { type = "list" default = [] }

variable "default_listener_protocol"  { default = "HTTPS" }
variable "vpc_enable_dns_hostnames"   { default = true}
variable "vpc_one_nat_gateway_per_az" { default = true}

variable "ragnar_listener_protocol"    { default = "HTTPS" }
variable "boston_rc_listener_protocol" { default = "HTTP" }

variable "freyr_listener_protocol" { default = "HTTPS" }

locals {
  local_tags = {
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Owner       = "${var.owner}"
    ManagedBy   = "terraform"
  }

  tags = "${merge(local.local_tags, var.tags)}"


  alb_zone_id  = "${module.product_alb.lb_zone_id}"
  alb_dns_name = "${module.product_alb.lb_dns_name}"
  ssl_arn      = "${module.r53.ssl_arn}"
  vpn_sg       = "${length(var.vpn_remote_state_bucket) > 0 && length(var.vpn_remote_state_key) > 0 ? data.terraform_remote_state.vpn.sg : "" }"

  private_dns_records = {
    "${local.rds_dns_record}"   = "${module.rds.endpoint}",
    "${local.redis_dns_record}" = "${lookup(module.redis.redis_details, "redis_endpoint", "")}",

  }

  rds_dns_name    = "${var.rds_dns}.private-${var.hosted_zone_name}"
  redis_dns_name  = "redis.private-${var.hosted_zone_name}"
  rds_dns_record     = "${var.rds_dns}"
  redis_dns_record   = "redis"


  #DIRTY HACK. Will be fixed by terraform. Must be updated with lenght
  private_dns_records_count = 12
}

variable "regions_azs" { type = "map" default = {"us-east-1" = ["us-east-1a", "us-east-1b", "us-east-1c"]}}
variable "tags"        { type = "map" }

variable "ecs_monitor"            { default = 0 }
variable "ecs_min_size"           { default = 1 }
variable "ecs_max_size"           { default = 2 }
variable "ecs_desired_size"       { default = 1 }
variable "ecs_instance_type"      { default = "t2.micro" }
variable "ecs_instance_root_size" { default = 10 }
variable "ecs_enable_ssh"         { default = false }

variable "efs_mount_point" { default = "/home/" }
variable "efs_mount_share" { default = "jenkins_slaves"}

variable "hosted_zone"      { default = "" }
variable "hosted_zone_name" { default = "" }
variable "ssl_certificate"  { default = "" }

variable "dns_records"     { type = "list"
  default = [
    "learn",
    "learn1"
  ]
}

variable task_complete_slack_channel {}

variable "alb_zone_id"      { default = "" }
variable "alb_dns_name"     { default = "" }
variable "rds_dns"          { default = "" }
variable "rds_dns_freyr"    { default = "" }
variable "r53_private_zone" { default = false }
#VPN
variable "vpn_remote_state_bucket" { default = "tf-remotestates" }
variable "vpn_remote_state_key"    { default = "" }
variable "vpn_remote_state_region" { default = "us-east-1" }

#GPU cluster parameters
variable "gpu_ami" { default =  "ami-0767a42a4d9197f04" } // Deep Learning AMI (Amazon Linux) Version x.y ami-034004f11a6ca94ec

variable "gpu_ecs_instance_root_size" { default = 75 }
variable "gpu_ecs_instance_type"      { default = "g3s.xlarge" }
variable "gpu_ecs_min_size"           { default = 1 }
variable "gpu_ecs_max_size"           { default = 1 }
variable "gpu_ecs_desired_size"       { default = 1 }


data "terraform_remote_state" "vpn" {
  backend = "s3"
  config {
    bucket = "${var.vpn_remote_state_bucket}"
    key    = "${var.vpn_remote_state_key}"
    region = "${var.vpn_remote_state_region}"
  }
}
