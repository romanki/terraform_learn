variable "environment"                {}
variable "project"                    {}
variable "owner"                      {}

variable "hosted_zone"           { default = "" }
variable "sll_certificate"       { default = "" }
variable "dns_records"           { type = "list" default = [] }
variable "alb_zone_id"           { default = "" }
variable "alb_dns_name"          { default = "" }

variable "vpc_id"                    { default = "" }
variable "private_dns_records_count" { default = 0 }
variable "private_cname_records"     { type = "map" default = {} }
variable "private_zone"              { default = false }
variable "private_hosted_zone"       { default = "" }

locals {
  tags = {
    Environment    = "${var.environment}"
    Project        = "${var.project}"
    Owner          = "${var.owner}"
    ManagedBy      = "terraform"
  }

  private_hosted_zone = "${length(var.private_hosted_zone) > 0 ? var.private_hosted_zone : "private-${var.hosted_zone}"}"
}
