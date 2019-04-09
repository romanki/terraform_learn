output "id" {
  value = "${aws_ecs_cluster.container_instance.id}"
}

output "name" {
  value = "${aws_ecs_cluster.container_instance.name}"
}

output "arn" {
  value = "${aws_ecs_cluster.container_instance.arn}"
}

output "container_instance_security_group_id" {
  value = "${aws_security_group.container_instance.id}"
}

output "container_instance_ecs_for_ec2_service_role_name" {
  value = "${aws_iam_role.container_instance_ec2.name}"
}

output "ecs_service_role_name" {
  value = "${aws_iam_role.ecs_service_role.name}"
}

output "ecs_autoscale_role_name" {
  value = "${aws_iam_role.ecs_autoscale_role.name}"
}

output "container_instance_autoscaling_group_name" {
  value = "${aws_autoscaling_group.container_instance.name}"
}

output "ecs_service_role_arn" {
  value = "${aws_iam_role.ecs_service_role.arn}"
}

output "ecs_autoscale_role_arn" {
  value = "${aws_iam_role.ecs_autoscale_role.arn}"
}

output "container_instance_ecs_for_ec2_service_role_arn" {
  value = "${aws_iam_role.container_instance_ec2.arn}"
}

output "ami_id" {
  value = "${local.ami_id}"
}


output "efs_dns" {
  value = "${aws_efs_file_system.efs.dns_name}"
}