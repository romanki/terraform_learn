variable "environment"       {}
variable "project"           {}
variable "service"           {}
variable "owner"             {}

variable "lb_arn"            {}
variable "lb_port"           {}
variable "target_port"       {}
variable "tg_healthcheck_matcher" { default = "200" }
variable "tags" { type = "map" default = {} }
variable "protocol" { default = "HTTP" }
variable "domain"   { default = "*.learn-learn.com" }
locals {
  local_tags = {
    Environment    = "${var.environment}"
    Project        = "${var.project}"
    Service        = "${var.service}"
    Owner          = "${var.owner}"
    ManagedBy      = "Terraform"
  }

  tags = "${merge(local.local_tags, var.tags)}"
}
variable "target_healthcheck" { default = "/" }
variable "ssl_arn"           { default = "" }
