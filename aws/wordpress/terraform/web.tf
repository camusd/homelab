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

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

# Create a launch configuration for web app
resource "aws_launch_configuration" "web_launch_conf" {
  name_prefix                 = "web_config-"
  image_id                    = "${var.web_ami_id}"
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
    db_name             = "${var.db_name}"
    db_username         = "${var.db_username}"
    db_password         = "${var.db_password}"
    db_host             = "${aws_db_instance.db.endpoint}"
    git_repo            = "${var.git_repo}"
    wp_auth_key         = "${var.wp_auth_key}"
    wp_secure_auth_key  = "${var.wp_secure_auth_key}"
    wp_logged_in_key    = "${var.wp_logged_in_key}"
    wp_nonce_key        = "${var.wp_nonce_key}"
    wp_auth_salt        = "${var.wp_auth_salt}"
    wp_secure_auth_salt = "${var.wp_secure_auth_salt}"
    wp_logged_in_salt   = "${var.wp_logged_in_salt}"
    wp_nonce_salt       = "${var.wp_nonce_salt}"
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