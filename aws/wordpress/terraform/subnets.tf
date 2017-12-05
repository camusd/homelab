# Create a VPC to launch our instances into
resource "aws_vpc" "main" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    tags {
        Name = "main"
    }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

# Create a routing table with a route to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "public"
  }
}

# Create a routing table with only local routing
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "private"
  }
}

# Create 2 public subnet to launch our web instances into for high availability
resource "aws_subnet" "subnet_1" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.subnet_1_cidr}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "public_subnet_1"
    }
}

resource "aws_subnet" "subnet_2" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.subnet_2_cidr}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "public_subnet_2"
    }
}

# Associate our public subnets to the public route table
resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.subnet_1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.subnet_2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Create 2 private subnets to launch our db instances into for high availability
resource "aws_subnet" "subnet_3" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.subnet_3_cidr}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "private_subnet_1"
    }
}

resource "aws_subnet" "subnet_4" {
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${var.subnet_4_cidr}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "private_subnet_2"
    }
}

# Associate our public subnets to the internet access route table
resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.subnet_3.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "d" {
  subnet_id      = "${aws_subnet.subnet_4.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Group our private subnets
resource "aws_db_subnet_group" "private_subnets" {
    name        = "private_subnet_group"
    description = "Our private group of subnets"
    subnet_ids  = ["${aws_subnet.subnet_3.id}", "${aws_subnet.subnet_4.id}"]
}