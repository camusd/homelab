resource "aws_security_group" "web_sg" {
    name        = "main_web_sg"
    description = "Allow HTTP inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "web_sg"
    }
}

resource "aws_security_group" "db_sg" {
    name        = "main_db_sg"
    description = "Allow RDS inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "db_sg"
    }
}