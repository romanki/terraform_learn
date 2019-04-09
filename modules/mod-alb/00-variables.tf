variable "environment"                {}
variable "project"                    {}
variable "service"                    {}
variable "owner"                      {}

variable "vpc_id"     { default = "" }
variable "subnet_ids" { type = "list" }

variable "domain"     { default = "" }

variable "cross_zone_load_balancing" { default = true }

variable "tags" { type = "map" default = {} }

locals {
  local_tags = {
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Service     = "${var.service}"
    Owner       = "${var.owner}"
    ManagedBy   = "Terraform"
  }

  tags = "${merge(local.local_tags, var.tags)}"
}
