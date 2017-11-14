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
  max_size                    = 3
  min_size                    = 1
  desired_capacity            = "2"
  vpc_zone_identifier         = ["${aws_subnet.url_shortener_1a.id}","${aws_subnet.url_shortener_1b.id}"]
  launch_configuration        = "${aws_launch_configuration.url_shortener.name}"
  health_check_type           = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "ecs_autoscaling_url_shortener" {
  name                   = "ecs_autoscaling_url_shortener"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 500
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}
