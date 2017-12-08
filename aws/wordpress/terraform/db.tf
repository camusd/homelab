# TODO: configure backups
resource "aws_db_instance" "db" {
    depends_on             = ["aws_security_group.db"]
    identifier             = "${var.db_identifier}"
    allocated_storage      = "${var.db_storage}"
    engine                 = "${var.db_engine}"
    engine_version         = "${lookup(var.db_engine_version, var.db_engine)}"
    instance_class         = "${var.db_instance_class}"
    name                   = "${var.db_name}"
    username               = "${var.db_username}"
    password               = "${var.db_password}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    db_subnet_group_name   = "${aws_db_subnet_group.db_subnets.id}"
    skip_final_snapshot    = true
    multi_az               = false

    lifecycle {
        create_before_destroy = true
  }
}

resource "aws_elasticache_cluster" "web-elasticache" {
  cluster_id           = "web-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  subnet_group_name    = "${aws_elasticache_subnet_group.elasticache_subnets.id}"
  security_group_ids   = ["${aws_security_group.redis.id}"]
}
