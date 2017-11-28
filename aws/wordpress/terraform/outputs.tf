output "subnet_group" {
    value = "${aws_db_subnet_group.default.name}"
}

output "web_instance_id" {
    value = "${aws_instance.web.id}"
}

output "db_instance_id" {
    value = "${aws_db_instance.db.id}"
}

output "db_instance_address" {
    value = "${aws_db_instance.db.address}"
}