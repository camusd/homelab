# TODO: configure backups
resource "aws_db_instance" "db" {
    depends_on             = ["aws_security_group.db_sg"]
    identifier             = "${var.db_identifier}"
    allocated_storage      = "${var.db_storage}"
    engine                 = "${var.db_engine}"
    engine_version         = "${lookup(var.db_engine_version, var.db_engine)}"
    instance_class         = "${var.db_instance_class}"
    name                   = "${var.db_name}"
    username               = "${var.db_username}"
    password               = "${var.db_password}"
    vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
    db_subnet_group_name   = "${aws_db_subnet_group.private_subnets.id}"
    skip_final_snapshot    = true
    multi_az               = true

    lifecycle {
        create_before_destroy = true
  }
}