# TODO: configure backups
resource "aws_db_instance" "db" {
    depends_on                  = ["aws_security_group.db"]
    identifier                  = "${var.db_identifier}"
    allocated_storage           = "${var.db_storage}"
    engine                      = "${var.db_engine}"
    engine_version              = "${lookup(var.db_engine_version, var.db_engine)}"
    instance_class              = "${var.db_instance_class}"
    name                        = "${var.db_name}"
    username                    = "${var.db_username}"
    password                    = "${var.db_password}"
    vpc_security_group_ids      = ["${aws_security_group.db.id}"]
    db_subnet_group_name        = "${aws_db_subnet_group.db_subnets.id}"
    backup_window               = "10:00-10:30"
    maintenance-window          = "sun:10:30-sun:11:30"
    final_snapshot_identifier   = "wordpress-rds-snapshot"
    backup_retention_period     = "1"
    apply_immediately           = false
    multi_az                    = false
    allow_major_version_upgrade = true
    auto_minor_version_upgrade  = true

    lifecycle {
        create_before_destroy = true
  }
}

data "aws_db_snapshot" "db_snapshot" {
  most_recent = true
  db_instance_identifier = "${aws_db_instance.db.identifier}"
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
