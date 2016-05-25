provider "aws" {
    region = "us-east-1"
}

variable "environment_name" {}

output "packer_subnet" {
    value="${aws_subnet.packer_subnet.id}"
}

output "packer_vpc" {
    value="${aws_vpc.packer.id}"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
    bucket = "${var.environment_name}_terraform_packer_state"
    acl = "private"
    versioning {
        enabled = true
    }
}

resource "aws_vpc" "packer" {
    cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "packer_gw" {
  vpc_id = "${aws_vpc.packer.id}"
}


resource "aws_subnet" "packer_subnet" {
    vpc_id = "${aws_vpc.packer.id}"
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_route_table" "packer_route_table" {
    vpc_id = "${aws_vpc.packer.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.packer_gw.id}"
    }
}

resource "aws_route_table_association" "packer_route_subnet" {
    subnet_id = "${aws_subnet.packer_subnet.id}"
    route_table_id = "${aws_route_table.packer_route_table.id}"
}
