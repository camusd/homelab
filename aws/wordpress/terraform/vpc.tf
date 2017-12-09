# Create a VPC to launch our instances into
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "main"
  }
}

# Create a DHCP Options Set to allow EC2 to resolve AWS DNS
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name         = "us-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

# Associate DHCP Options Set to main VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "igw"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_1.id}"
  depends_on    = ["aws_internet_gateway.igw"]

  tags {
    Name = "nat"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

# Create a routing table with a route to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "public"
  }
}

# Create a routing table with only local routing
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "private"
  }
}

# Create 2 public subnet to launch our elbs into for high availability
resource "aws_subnet" "public_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_1_cidr}"
  availability_zone = "${var.az_1}"

  tags {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_2_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "public_2"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = "${aws_subnet.public_1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = "${aws_subnet.public_2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "public" {
  vpc_id = "${aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.public_1.id}", "${aws_subnet.public_2.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  tags {
    Name = "public"
  }
}

# Create 2 private subnets to launch our db instances into for high availability
resource "aws_subnet" "db_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.db_1_cidr}"
  availability_zone = "${var.az_1}"

  tags {
    Name = "db_1"
  }
}

resource "aws_subnet" "db_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.db_2_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "db_2"
  }
}

resource "aws_route_table_association" "db_1" {
  subnet_id      = "${aws_subnet.db_1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "db_2" {
  subnet_id      = "${aws_subnet.db_2.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_db_subnet_group" "db_subnets" {
  name        = "db_subnet_group"
  description = "Our private group of db subnets"
  subnet_ids  = ["${aws_subnet.db_1.id}", "${aws_subnet.db_2.id}"]
}

resource "aws_elasticache_subnet_group" "elasticache_subnets" {
  name        = "elasticache-subnet-group"
  description = "Our private group of elasticache subnets"
  subnet_ids  = ["${aws_subnet.db_1.id}", "${aws_subnet.db_2.id}"]
}

resource "aws_network_acl" "db" {
  vpc_id = "${aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.db_1.id}", "${aws_subnet.db_2.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 6379
    to_port    = 6379
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 1024
    to_port    = 65535
  }

  tags {
    Name = "db"
  }
}

# Create 2 private subnets to launch our web instances into for high availability
resource "aws_subnet" "web_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.web_1_cidr}"
  availability_zone = "${var.az_1}"

  tags {
    Name = "web_1"
  }
}

resource "aws_subnet" "web_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.web_2_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "web_2"
  }
}

resource "aws_route_table_association" "web_1" {
  subnet_id      = "${aws_subnet.web_1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "web_2" {
  subnet_id      = "${aws_subnet.web_2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "web" {
  vpc_id = "${aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.web_1.id}", "${aws_subnet.web_2.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 25
    to_port    = 25
  }

  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 6379
    to_port    = 6379
  }

  egress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 1024
    to_port    = 65535
  }

  tags {
    Name = "web"
  }
}

# Create a public subnet to launch our bastion host into
resource "aws_subnet" "bastion" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.bastion_cidr}"
  availability_zone = "${var.az_1}"

  tags {
    Name = "bastion"
  }
}

# Associate our bastion host subnet to the public route table
resource "aws_route_table_association" "bastion" {
  subnet_id      = "${aws_subnet.bastion.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "bastion" {
  vpc_id = "${aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.bastion.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  tags {
    Name = "bastion"
  }
}
