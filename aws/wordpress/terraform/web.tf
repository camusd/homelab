# Get the most recent golden web ami
data "aws_ami" "web_ami" {
    most_recent = true
    owners      = ["self"]
    name_regex  = "web-golden"

    filter {
        name = "tag:Name"
        values = ["web"]
    }
}

# Create an ELB to serve traffic to web ASG
resource "aws_elb" "web_elb" {
  name_prefix     = "web-"
  subnets         = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
  security_groups = ["${aws_security_group.web_elb_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a launch configuration for web app
resource "aws_launch_configuration" "web_launch_conf" {
  name_prefix                 = "web_config-"
  image_id                    = "${data.aws_ami.web_ami.id}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.web_sg.id}"]
  key_name                    = "${var.aws_key_name}"
  user_data                   = "${data.template_file.web_user_data.rendered}"
  associate_public_ip_address = true
  
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "web_user_data" {
  template = "${file("./web-user-data.tpl")}"

  vars {
    efs_dns_name         = "${aws_efs_file_system.web_efs.dns_name}"
  }
}

# Create an autoscaling group in 2 difference AZs for high availability
resource "aws_autoscaling_group" "web_asg" {
  depends_on                 = ["aws_db_instance.db"]
  name_prefix                = "web_asg-"
  launch_configuration       = "${aws_launch_configuration.web_launch_conf.name}"
  min_size                   = 2
  max_size                   = 4
  desired_capacity           = 2
  vpc_zone_identifier        = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
  health_check_grace_period  = 300
  health_check_type          = "ELB"
  load_balancers             = ["${aws_elb.web_elb.id}"]
  force_delete               = true

  lifecycle {
    create_before_destroy = true
  }

  tag {
      key                 = "Name"
      value               = "web"
      propagate_at_launch = true
  }
}

resource "aws_elasticache_cluster" "web" {
  cluster_id           = "web-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  subnet_group_name    = "${aws_elasticache_subnet_group.private_subnets.id}"
  security_group_ids   = ["${aws_security_group.redis_sg.id}"]
}

resource "aws_efs_file_system" "web_efs" {
  creation_token = "wordpress"

  tags {
      Name = "web"
  }
}

resource "aws_efs_mount_target" "subnet_1" {
  file_system_id  = "${aws_efs_file_system.web_efs.id}"
  subnet_id       = "${aws_subnet.subnet_1.id}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

resource "aws_efs_mount_target" "subnet_2" {
  file_system_id  = "${aws_efs_file_system.web_efs.id}"
  subnet_id       = "${aws_subnet.subnet_2.id}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

resource "aws_autoscaling_policy" "web_asg_policy" {
  name                   = "web_asg_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.web_asg.name}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.aws_public_key_path)}"
}
