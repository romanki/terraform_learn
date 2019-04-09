variable "owner"    { default = "" }
variable "env"      { default = "" }
variable "platform" { default = "" }
variable "service"  { default = "redis" }

variable "region" {}
variable "azs"    { type = "list" }

variable "vpc_id"   {}
variable "vpc_cidr" {}

variable "inbound_sg_ecs" { default = "" }

variable "subnets_redis" { type = "list" }
variable "subnet_redis_route_table"  { }

variable "cluster_redis_node_num"  { default = 1 }
variable "cluster_redis_node_type" { default = "cache.t2.micro" }
variable "cluster_redis_name"      {}
