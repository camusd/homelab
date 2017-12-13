resource "aws_security_group" "web_elb" {
  name        = "web_elb"
  description = "Allows public HTTP inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "web_elb"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allows public SSH inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.home_ip}", "${var.work_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "bastion"
  }
}

resource "aws_security_group" "web" {
    name        = "web"
    description = "Allow private HTTP and bastion host SSH inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    }

    ingress {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = ["${aws_security_group.web_elb.id}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "web"
    }
}

resource "aws_security_group" "efs_client" {
    name        = "efs_client"
    description = "Allow connection to efs"
    vpc_id      = "${aws_vpc.main.id}"

    tags {
        Name = "efs_client"
    }
}

resource "aws_security_group" "efs_backup_client" {
    name        = "efs_backup_client"
    description = "Allow connection to efs backup"
    vpc_id      = "${aws_vpc.main.id}"

    tags {
        Name = "efs_backup_client"
    }
}

resource "aws_security_group" "db" {
    name        = "db"
    description = "Allow private MySQL and bastion host SSH inbound traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    }

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "db"
    }
}

resource "aws_security_group" "efs" {
    name        = "efs"
    description = "Allow private NFS traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port       = 2049
        to_port         = 2049
        protocol        = "tcp"
        security_groups = ["${aws_security_group.efs_client.id}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "efs"
    }
}

resource "aws_security_group" "efs_backup" {
    name        = "efs_backup"
    description = "Allow private NFS traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port       = 2049
        to_port         = 2049
        protocol        = "tcp"
        security_groups = ["${aws_security_group.efs_backup_client.id}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "efs_backup"
    }
}

resource "aws_security_group" "redis" {
    name        = "redis"
    description = "Allow private Redis traffic"
    vpc_id      = "${aws_vpc.main.id}"

    ingress {
        from_port       = 6379
        to_port         = 6379
        protocol        = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "redis"
    }
}
