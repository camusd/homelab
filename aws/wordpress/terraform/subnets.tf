resource "aws_vpc" "main" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "dedicated"

    tags {
        Name = "main"
    }
}

resource "aws_subnet" "subnet_1" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.subnet_1_cidr}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "main_subnet1"
    }
}

resource "aws_subnet" "subnet_2" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.subnet_2_cidr}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "main_subnet2"
    }
}

resource "aws_db_subnet_group" "default" {
    name        = "main_subnet_group"
    description = "Our main group of subnets"
    subnet_ids  = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
}