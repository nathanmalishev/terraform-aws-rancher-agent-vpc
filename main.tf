resource "aws_vpc" "pinger-cluster-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pinger-cluster-subnet" {
  vpc_id   = "${aws_vpc.pinger-cluster-vpc.id}"
  map_public_ip_on_launch = true
}