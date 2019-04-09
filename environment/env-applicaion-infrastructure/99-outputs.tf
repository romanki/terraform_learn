output "ecs-cluster-name" { value = "${module.ecs.name}" }
output "ecs_cluster_name" { value = "${module.ecs.name}" }
output "ecs_cluster_arn"  { value = "${module.ecs.arn}" }

# Microservice load balancer details

output "rds_dns"              { value = "${local.rds_dns_name}" }
output "gpu_ecs_cluster_name" { value = "${module.ecs_gpu.name}" }
output "gpu_ecs_cluster_arn"  { value = "${module.ecs_gpu.arn}" }

output "vpc_id"          { value = "${module.vpc.vpc_id}" }
output "ecs_task_sg_id"  { value = "${aws_security_group.ecs_task.id}"}
output "private_subnets" { value = "${module.vpc.private_subnets}"}
