module "ecs_gpu" {
  source = "../../modules/mod-ecs"

  environment     = "${var.environment}"
  service         = "${var.service}"
  owner           = "${var.owner}"
  cluster_name    = "${var.environment}-${var.service}-GPU-Cluster"
  tags            = "${local.tags}"

  vpc_id               = "${module.vpc.vpc_id}"
  instance_type        = "${var.gpu_ecs_instance_type}"
  //ami_id               = "${var.gpu_ami}"
  key_name             = "${var.ecs_enable_ssh ? "key" : ""}"
  cloud_config_content = ""
  private_subnet_ids   = [ "${module.vpc.private_subnets}" ]

  root_block_device_type = "gp2"
  root_block_device_size = "${var.gpu_ecs_instance_root_size}"

  desired_capacity          = "${var.gpu_ecs_desired_size}"
  min_size                  = "${var.gpu_ecs_min_size}"
  max_size                  = "${var.gpu_ecs_max_size}"

  foxpass_sm               = "aws_sm"

  userdata_ecs_agent      = false
  userdata_nvidia_drivers = true

  lookup_latest_ami = true
  latest_ami_name   = "amzn2-ami-ecs-gpu-hvm-*-x86_64-ebs"
}

resource "aws_security_group_rule" "ingress_allow_all_ecs_gpu" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${module.ecs_gpu.container_instance_security_group_id}"
}

resource "aws_security_group_rule" "egress_allow_all_ecs_gpu" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${module.ecs_gpu.container_instance_security_group_id}"
}
