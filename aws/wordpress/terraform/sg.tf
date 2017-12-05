# Public HTTP access for ELB
resource "aws_security_group" "web_elb_sg" {
  name        = "web_elb_sg"
  description = "Allows public HTTP inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "web_elb_asg"
  }
}

# Private HTTP access and SSH from anywhere for web instances
resource "aws_security_group" "web_sg" {
    name        = "main_web_sg"
    description = "Allow public SSH and private HTTP inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${aws_vpc.main.cidr_block}"]
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

# SSH and RDS access for db instances
resource "aws_security_group" "db_sg" {
    name        = "main_db_sg"
    description = "Allow private RDS and public SSH inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["${aws_vpc.main.cidr_block}"]
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