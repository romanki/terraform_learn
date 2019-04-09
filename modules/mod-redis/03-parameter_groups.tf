resource "aws_elasticache_parameter_group" "redis" {
  name        = "${var.owner}-${var.env}-${var.platform}-${var.service}-params"
  description = "${var.owner}-${var.env}-${var.platform} Redis Parameters Group"
  family      = "redis3.2"

  parameter {
    name  = "activerehashing"
    value = "yes"
  }
}
