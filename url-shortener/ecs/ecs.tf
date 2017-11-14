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
  depends_on = ["aws_iam_policy_attachment.ecs_service", "aws_alb.url_shortener"]

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.url_shortener.arn}"
    container_name = "url-shortener"
    container_port = 5000
  }

  # load_balancer {
  #     elb_name = "${aws_elb.url_shortener.id}"
  #     container_name = "url-shortener"
  #     container_port = 5000
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
  # }
}
