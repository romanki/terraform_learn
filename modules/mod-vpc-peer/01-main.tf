resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id   = "${var.vpc_1_id}"
  vpc_id        = "${var.vpc_2_id}"
  tags = {
    Name = "${var.vpc_1_name}-to-${var.vpc_2_name}-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
  auto_accept               = true
  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "default_to_app" {
  route_table_id = "${var.vpc_1_public_route_table_id}"
  destination_cidr_block = "${var.vpc_2_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
}

resource "aws_route" "default_to_app_private" {
  route_table_id = "${var.vpc_1_private_route_table_id}"
  destination_cidr_block = "${var.vpc_2_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
}

resource "aws_route" "app_to_default" {
  route_table_id = "${var.vpc_2_public_route_table_id}"
  destination_cidr_block = "${var.vpc_1_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
}

resource "aws_route" "app_to_default_private" {
  route_table_id = "${var.vpc_2_private_route_table_id}"
  destination_cidr_block = "${var.vpc_1_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
}