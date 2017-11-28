resource "aws_db_instance" "db" {
    depends_on             = ["aws_security_group.db-sg"]
    identifier             = "${var.db_identifier}"
    allocated_storage      = "${var.db_storage}"
    engine                 = "${var.db_engine}"
    engine_version         = "${lookup(var.db_engine_version, var.db_engine)}"
    instance_class         = "${var.db_instance_class}"
    name                   = "${var.db_name}"
    username               = "${var.db_username}"
    password               = "${var.db_password}"
    vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
    db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
}