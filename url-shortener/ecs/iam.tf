resource "aws_iam_role" "ecs_service" {
  name = "ecs_service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "app_autoscale" {
  name = "app_autoscale"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "app_autoscale" {
  name       = "app_autoscale"
  roles      = ["${aws_iam_role.app_autoscale.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_policy" "url_shortener" {
  # dynamodb resource could be created for safety reasons
  name        = "url_shortener"
  description = "Terraform based"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": [
      "dynamodb:*"
    ],
    "Effect": "Allow",
    "Resource": "*"
  }
]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_service" {
  name       = "ecs_service"
  roles      = ["${aws_iam_role.ecs_service.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role" "ecs_instances" {
  name = "ecs_instances"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_instances_attach" {
  name       = "ecs_instance_attach"
  roles      = ["${aws_iam_role.ecs_instances.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "url_shortener" {
  name       = "url_shortener"
  roles      = ["${aws_iam_role.ecs_instances.name}"]
  policy_arn = "${aws_iam_policy.url_shortener.arn}"
}
