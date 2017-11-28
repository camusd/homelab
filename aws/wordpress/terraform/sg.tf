resource "aws_security_group" "db-sg" {
    name        = "main_db_sg"
    description = "Allow RDS inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "TCP"
        cidr_blocks = ["${var.cidr_blocks}"]
    }
    
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "${var.db_sg_name}"
    }
}