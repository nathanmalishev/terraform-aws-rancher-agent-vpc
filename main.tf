### Required Variables ####

variable "vpc_name" {
    description = "The name of the VPC. Best not to include non-alphanumeric characters."
}

variable "vpc_region" {
    description = "Target region for the VPC"
}

variable "vpc_nat_key_file" {
    description = "Path to a key file for the VPC NAT instance"
}

### resources ###

resource "aws_vpc" "default" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags {
      Name = "${var.vpc_name}"
      ManagedBy = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
      Name = "${var.vpc_name}-Internet-Gateway"
      VPC = "${var.vpc_name}"
      ManagedBy = "terraform"
  }

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_subnet" "default-subnet" {
  vpc_id   = "${aws_vpc.default.id}"
  map_public_ip_on_launch = true
  cidr_block = "10.1.1.0/24"
    
  tags {
      Name = "${var.vpc_name}"
      ManagedBy = "terraform"
  }

  lifecycle {
      create_before_destroy = true
  }
}


# Routes through the internet gateway
resource "aws_route_table" "public_routes" {

  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "${var.vpc_name}-Public-Routing"
    VPC = "${var.vpc_name}"
    ManagedBy = "terraform"
  }

}

# Public subnet 1
resource "aws_route_table_association" "public_table" {

  subnet_id = "${aws_subnet.default-subnet.id}"
  route_table_id = "${aws_route_table.public_routes.id}"

}

### Outputs ###

output "vpc_id" {
    value = "${aws_vpc.default.id}"
}

output "vpc_region" {
    value = "${var.vpc_region}"
}

output "vpc_public_subnet" {
    value = "${aws_subnet.default-subnet.cidr_block}"
}
output "vpc_public_subnet_id" {
    value = "${aws_subnet.default-subnet.id}"
}
