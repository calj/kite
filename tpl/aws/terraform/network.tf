# Create a VPC to launch our instances into
resource "aws_vpc" "platform" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "${var.vpc_name}"
    Component = "kite-platform"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "platform" {
  vpc_id = "${aws_vpc.platform.id}"
  tags {
    Name = "platform-gateway"
    Component = "kite-platform"
  }
}

# Create a subnet to launch our instances into
resource "aws_subnet" "platform_net" {
  vpc_id = "${aws_vpc.platform.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block = "${var.subnet_cidr}"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.subnet_name}"
    Component = "kite-platform"
  }
}

# Allocate an Elastic IP for NAT gateway
resource "aws_eip" "nat_ip" {
}

# Create a NAT gateway to forward the traffic for BOSH
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_ip.id}"
  subnet_id = "${aws_subnet.platform_net.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.platform.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.platform.id}"
}

# Create a custom route table for the private subnet
resource "aws_route_table" "bosh_private" {
  vpc_id = "${aws_vpc.platform.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  tags {
    Name = "platform-route"
    Component = "kite-platform"
  }
}

# Associate custom route table with private subnet
resource {
  subnet_id      = "${aws_subnet.platform_net.id}"
  route_table_id = "${aws_route_table.bosh_private.id}"
}

# The default security group
resource "aws_security_group" "bosh_sg" {
  name = "bosh_sg"
  description = "Default BOSH security group"
  vpc_id = "${aws_vpc.platform.id}"
  tags {
    Name = "bosh-sq"
    Component = "bosh-director"
  }

  # inbound access rules
  ingress {
    from_port = 6868
    to_port = 6868
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 25555
    to_port = 25555
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    self = true
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

# Create a Concourse security group
resource "aws_security_group" "concourse_sg" {
  name        = "concourse-sg"
  description = "Concourse security group"
  vpc_id      = "${aws_vpc.platform.id}"
  tags {
    Name = "concourse-sg"
    Component = "concourse"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound connections from ELB
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
