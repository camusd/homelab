# Get the most recent base web ami
data "aws_ami" "web_ami" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "web-base"

  filter {
    name = "tag:Name"
    values = ["web"]
  }
}

# Get the most recent bastion ami
data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }
}

# Create an ELB to serve traffic to web ASG
resource "aws_elb" "web_elb" {
  name_prefix     = "web-"
  subnets         = ["${aws_subnet.public_1.id}", "${aws_subnet.public_2.id}"]
  security_groups = ["${aws_security_group.web_elb.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.cert.arn}"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:80"
    interval            = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "*.dylancamus.com"
}

# Create a launch configuration for web app
resource "aws_launch_configuration" "web_launch_conf" {
  name_prefix                 = "web_config-"
  image_id                    = "${data.aws_ami.web_ami.id}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.web.id}"]
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
    efs_dns_name = "${aws_efs_file_system.web_efs.dns_name}"
  }
}

# Create an autoscaling group in 2 difference AZs for high availability
resource "aws_autoscaling_group" "web_asg" {
  depends_on                 = ["aws_db_instance.db"]
  name_prefix                = "web_asg-"
  launch_configuration       = "${aws_launch_configuration.web_launch_conf.name}"
  min_size                   = 1
  max_size                   = 5
  vpc_zone_identifier        = ["${aws_subnet.web_1.id}", "${aws_subnet.web_2.id}"]
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

resource "aws_cloudwatch_metric_alarm" "web_cpu_metric" {
  alarm_name          = "web_cpu_metric"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_asg.name}"
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = ["${aws_autoscaling_policy.web_asg_policy.arn}"]
}

resource "aws_efs_file_system" "web_efs" {
  creation_token = "wordpress"

  tags {
      Name = "web"
  }
}

resource "aws_efs_mount_target" "web_1" {
  file_system_id  = "${aws_efs_file_system.web_efs.id}"
  subnet_id       = "${aws_subnet.web_1.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "web_2" {
  file_system_id  = "${aws_efs_file_system.web_efs.id}"
  subnet_id       = "${aws_subnet.web_2.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.aws_public_key_path)}"
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.bastion.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.bastion.id}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  key_name                    = "${var.aws_key_name}"
  associate_public_ip_address = true

  tags {
    Name = "bastion"
  }
}
