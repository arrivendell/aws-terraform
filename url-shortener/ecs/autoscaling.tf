resource "template_file" "cloud_init_command" {
    template = "${file("templates/cloud_init_command")}"
    vars {
        cluster_name = "url_shortener"
    }
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
    name = "ecs_instance_profile"
    role = "${aws_iam_role.ecs_instances.name}"
}

resource "aws_launch_configuration" "url_shortener" {
  name                        = "url_shortener"
  image_id                    = "ami-014ae578"
  instance_type               = "t2.micro"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  security_groups             = ["${aws_security_group.instances_default_sg.id}"]
  associate_public_ip_address = "true"
  key_name                    = "webinst"
  user_data = "${template_file.cloud_init_command.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                        = "url_shortener"
  max_size                    = 4
  min_size                    = 1
  desired_capacity            = "2"
  vpc_zone_identifier         = ["${aws_subnet.url_shortener_1a.id}","${aws_subnet.url_shortener_1b.id}"]
  launch_configuration        = "${aws_launch_configuration.url_shortener.name}"
  health_check_type           = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "increase_autoscaling_ec2_url_shortener" {
  name                   = "increase_autoscaling_ec2_url_shortener"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 500
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}


resource "aws_autoscaling_policy" "decrease_autoscaling_ec2_url_shortener" {
  name                   = "decrease_autoscaling_ec2_url_shortener"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 500
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}

resource "aws_cloudwatch_metric_alarm" "CPU_url_shortener_high_utilization" {
  alarm_name          = "CPU-url-shortener-high-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  }

  alarm_description = "EC2 cpu high usage"
  alarm_actions     = ["${aws_autoscaling_policy.increase_autoscaling_ec2_url_shortener.arn}", "${aws_appautoscaling_policy.increase_url_shortener.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "CPU_url_shortener_low_utilization" {
  alarm_name          = "CPU-url-shortener-low-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  }

  alarm_description = "EC2 cpu low usage"
  alarm_actions     = ["${aws_autoscaling_policy.decrease_autoscaling_ec2_url_shortener.arn}", "${aws_appautoscaling_policy.decrease_url_shortener.arn}"]
}
