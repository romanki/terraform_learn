# Container Instance IAM resources
data "aws_iam_policy_document" "container_instance_ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_ec2" {
  name               = "${var.environment}-ContainerInstance-${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_ec2_assume_role.json}"

  tags = "${local.tags}"
}

resource "aws_iam_role_policy_attachment" "ec2_service_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_full_access_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess" # could probably be limited to a custom ecs:* policy
}

resource "aws_iam_instance_profile" "container_instance" {
  name = "${aws_iam_role.container_instance_ec2.name}"
  role = "${aws_iam_role.container_instance_ec2.name}"
}

# ECS Service IAM permissions
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.environment}-EcsServiceRole-${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role.json}"

  tags = "${local.tags}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role" {
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_autoscale_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_autoscale_role" {
  name               = "${var.environment}-EcsAutoscaleRole-${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_autoscale_assume_role.json}"

  tags = "${local.tags}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_autoscaling_role" {
  role       = "${aws_iam_role.ecs_autoscale_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

# Security group resources
resource "aws_security_group" "container_instance" {
  name = "${var.environment}-${var.service}-ContainerInstanceSecurityGroup-${var.cluster_name}"

  vpc_id = "${var.vpc_id}"

  tags = "${merge(local.tags, map("Name", "${var.environment}-ContainerInstanceSecurityGroup-${var.cluster_name}"))}"
}

# AutoScaling resources
data "template_file" "container_instance_base_cloud_config" {
  template = "${file("${path.module}/cloud-config/base-container-instance.yml.tpl")}"

  vars {
    ecs_cluster_name = "${aws_ecs_cluster.container_instance.name}"
  }
}

data "template_file" "clean_docker" {
  template = "${file("${path.module}/cloud-config/clean-docker.sh")}"
}

data "template_file" "mount_efs" {
  template = "${file("${path.module}/cloud-config/mount-efs.sh")}"

  vars {
    EFS_DNS         = "${aws_efs_file_system.efs.dns_name}"
    EFS_MOUNT_POINT = "${var.efs_mount_point}"
  }
}

data "template_file" "install_foxpass" {
  template = "${file("${path.module}/cloud-config/install-foxpass.sh")}"

  vars {
    foxpass_bind_pw = "${local.foxpass_bind_pwd}"
    foxpass_api_key = "${local.foxpass_api_key}"
  }
}

data "template_file" "install_ecs_init" {
  template = "${file("${path.module}/cloud-config/install-ecs-init.sh")}"
}

data "template_file" "install_nvidia_drivers" {
  template = "${file("${path.module}/cloud-config/install-nvidia-drivers.sh")}"
}

data "template_cloudinit_config" "container_instance_cloud_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.container_instance_base_cloud_config.rendered}"
  }

  part {
    content_type = "${var.cloud_config_content_type}"
    content      = "${var.cloud_config_content}"
  }
  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.clean_docker.rendered}"
  }
  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.mount_efs.rendered}"
  }
  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.install_foxpass.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content = "${var.userdata_ecs_agent ? data.template_file.install_ecs_init.rendered : ""}"
  }

  part {
    content_type = "text/x-shellscript"
    content = "${var.userdata_nvidia_drivers ? data.template_file.install_nvidia_drivers.rendered : ""}"
  }
}

resource "aws_launch_configuration" "container_instance" {
  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "${var.root_block_device_type}"
    volume_size = "${var.root_block_device_size}"
  }

  name_prefix          = "${var.environment}-ContainerInstanceLc-${var.cluster_name}-"
  iam_instance_profile = "${aws_iam_instance_profile.container_instance.name}"

  # Using join() is a workaround for depending on conditional resources.
  # https://github.com/hashicorp/terraform/issues/2831#issuecomment-298751019
  image_id = "${local.ami_id}"

  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.container_instance.id}"]
  user_data       = "${data.template_cloudinit_config.container_instance_cloud_config.rendered}"
}

resource "aws_autoscaling_group" "container_instance" {
  lifecycle {
    create_before_destroy = true
    //ignore_changes = [ "desired_capacity" ]
  }

  name                      = "${var.environment}-ContainerInstanceAsg-${var.cluster_name}"
  launch_configuration      = "${aws_launch_configuration.container_instance.name}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "EC2"
  desired_capacity          = "${var.desired_capacity}"
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  vpc_zone_identifier       = ["${var.private_subnet_ids}"]

  tags = [
    {
      key                 = "Name",
      value               = "${var.environment}-EcsContainerInstance-${var.cluster_name}",
      propagate_at_launch = true
    }
  ]

  tags = [ "${data.null_data_source.asg_local_tags.*.outputs}" ]
}

# This is a stupid way of using a null_data_source to transpose a typical local_tags map to aws_autoscaling_group tag format
data "null_data_source" "asg_local_tags" {
  count = "${length(keys(local.local_tags))}"

  inputs = {
    key = "${element(keys(local.local_tags), count.index)}"
    value = "${element(values(local.local_tags), count.index)}"
    propagate_at_launch = true
  }
}

# ECS resources
resource "aws_ecs_cluster" "container_instance" {
  name = "${var.environment}-EcsCluster-${var.cluster_name}"

  tags = "${local.tags}"
}

# CloudWatch resources
resource "aws_autoscaling_policy" "container_instance_scale_up" {
  name                   = "${var.environment}-AsgScalingPolicyClusterScaleUp-${var.cluster_name}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.scale_up_cooldown_seconds}"
  autoscaling_group_name = "${aws_autoscaling_group.container_instance.name}"
}

resource "aws_autoscaling_policy" "container_instance_scale_down" {
  name                   = "${var.environment}-AsgScalingPolicyClusterScaleDown-${var.cluster_name}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.scale_down_cooldown_seconds}"
  autoscaling_group_name = "${aws_autoscaling_group.container_instance.name}"
}

resource "aws_cloudwatch_metric_alarm" "container_instance_high_cpu" {
  alarm_name          = "${var.environment}-AlarmClusterCPUReservationHigh-${var.cluster_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_cpu_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.high_cpu_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.high_cpu_threshold_percent}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.container_instance.name}"
  }

  alarm_description = "Scale up if CPUReservation is above N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "container_instance_low_cpu" {
  alarm_name          = "${var.environment}-AlarmClusterCPUReservationLow-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_cpu_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.low_cpu_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.low_cpu_threshold_percent}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.container_instance.name}"
  }

  alarm_description = "Scale down if the CPUReservation is below N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_down.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.container_instance_high_cpu"]
}

resource "aws_cloudwatch_metric_alarm" "container_instance_high_memory" {
  alarm_name          = "${var.environment}-AlarmClusterMemoryReservationHigh-${var.cluster_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_memory_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.high_memory_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.high_memory_threshold_percent}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.container_instance.name}"
  }

  alarm_description = "Scale up if the MemoryReservation is above N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_up.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.container_instance_low_cpu"]
}

resource "aws_cloudwatch_metric_alarm" "container_instance_low_memory" {
  alarm_name          = "${var.environment}-AlarmClusterMemoryReservationLow-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_memory_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.low_memory_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.low_memory_threshold_percent}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.container_instance.name}"
  }

  alarm_description = "Scale down if the MemoryReservation is below N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.container_instance_scale_down.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.container_instance_high_memory"]
}
