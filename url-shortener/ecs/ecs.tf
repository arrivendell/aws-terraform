provider "aws" {
  region = "eu-west-1"
}

resource "aws_ecs_task_definition" "url_shortener" {
  family                = "url_shortener_family"
  container_definitions = "${file("tasks-definitions/service.json")}"

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
  # }
}

resource "aws_ecs_cluster" "url_shortener" {
  name = "url_shortener"
}

resource "aws_ecs_service" "url_shortener" {
  name            = "url_shortener"
  cluster         = "${aws_ecs_cluster.url_shortener.id}"
  task_definition = "${aws_ecs_task_definition.url_shortener.arn}"
  desired_count   = 2
  iam_role        = "${aws_iam_role.ecs_service.arn}"
  depends_on      = ["aws_iam_policy_attachment.ecs_service", "aws_alb.url_shortener"]

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.url_shortener.arn}"
    container_name   = "url-shortener"
    container_port   = 5000
  }

  # load_balancer {
  #     elb_name = "${aws_elb.url_shortener.id}"
  #     container_name = "url-shortener"
  #     container_port = 5000
  # }

  # To reactivate to have service in several zones
  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
  # }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.url_shortener.name}/${aws_ecs_service.url_shortener.name}"
  role_arn           = "${aws_iam_role.app_autoscale.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "increase_url_shortener" {
  name               = "increase_url_shortener"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.url_shortener.name}/${aws_ecs_service.url_shortener.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 200
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_appautoscaling_policy" "decrease_url_shortener" {
  name               = "increase_url_shortener"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.url_shortener.name}/${aws_ecs_service.url_shortener.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 200
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}
