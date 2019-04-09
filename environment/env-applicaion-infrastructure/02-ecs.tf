module "ecs" {
  source = "../../modules/mod-ecs"

  environment     = "${var.environment}"
  service         = "${var.service}"
  owner           = "${var.owner}"
  cluster_name    = "${var.service}"
  tags            = "${local.tags}"

  vpc_id            = "${module.vpc.vpc_id}"
  lookup_latest_ami = true
  instance_type     = "${var.ecs_instance_type}"

  key_name             = "${var.ecs_enable_ssh ? "key" : ""}"
  cloud_config_content = ""

  private_subnet_ids = [ "${module.vpc.private_subnets}" ]

  root_block_device_type = "gp2"
  root_block_device_size = "${var.ecs_instance_root_size}"

  health_check_grace_period = "600"
  desired_capacity          = "${var.ecs_desired_size}"
  min_size                  = "${var.ecs_min_size}"
  max_size                  = "${var.ecs_max_size}"

  foxpass_sm = "aws_sm"
}

resource "aws_security_group_rule" "ingress_allow_all" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${module.ecs.container_instance_security_group_id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${module.ecs.container_instance_security_group_id}"
}

resource "aws_security_group" "ecs_task" {
  name        = "${var.environment}-ecs-task-sg"
  description = "Security group for single ecs tasks"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${var.tags}"
}

resource "aws_security_group_rule" "task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ecs_task.id}"
}
