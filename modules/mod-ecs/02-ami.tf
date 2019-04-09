data "aws_ami" "ecs_ami" {
  count       = "${var.lookup_latest_ami}"
  most_recent = true
  owners = ["${var.ami_owners}"]

  filter {
    name   = "name"
    values = ["${var.latest_ami_name}"]
  }

  filter {
    name   = "owner-alias"
    values = ["${var.ami_owners}"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "user_ami" {
  count  = "${1 - var.lookup_latest_ami}"
  owners = ["${var.ami_owners}"]

  filter {
    name   = "image-id"
    values = ["${var.ami_id}"]
  }
}

locals {
  ami_id = "${var.lookup_latest_ami ? join("", data.aws_ami.ecs_ami.*.image_id) : join("", data.aws_ami.user_ami.*.image_id)}"
}
