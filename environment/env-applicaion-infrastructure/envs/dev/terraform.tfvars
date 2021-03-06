aws_region        = "us-east-1"
account_prefix    = "dev"
environment       = "dev"
environment_short = "dev"
owner             = "learn"
service           = "product"

#ECS VPC
vpc_azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_cidr        = "10.60.0.0/16"
private_subnets = ["10.60.1.0/24", "10.60.2.0/24", "10.60.3.0/24"]
public_subnets  = ["10.60.101.0/24", "10.60.102.0/24", "10.60.103.0/24"]
vpc_enable_dns_hostnames   = true
vpc_enable_nat_gateway     = true
vpc_single_nat_gateway     = false
vpc_one_nat_gateway_per_az = true
tags = {}

#ECS ECS Linux
ecs_instance_type = "c5.xlarge"
ecs_enable_ssh    = true

ecs_min_size      = 3
ecs_max_size      = 4
ecs_desired_size  = 3

ecs_instance_root_size = 16

#ECS ECS Linux GPU
gpu_ami                    = "ami-034004f11a6ca94ec"
gpu_ecs_instance_root_size = 75

gpu_ecs_instance_type      = "g3s.xlarge"

gpu_ecs_min_size     = 1
gpu_ecs_max_size     = 1
gpu_ecs_desired_size = 1

#ECS R53
hosted_zone      = "learn-development.com."
hosted_zone_name = "learn-development.com"
ssl_certificate  = "*.learn-development.com"
rds_dns          = "rds_dev"
r53_private_zone = true

#ECS VPN
vpn_remote_state_bucket = "tf-remotestates"
vpn_remote_state_key    = "dev/vpn.tfstate"
vpn_remote_state_region = "us-east-1"


