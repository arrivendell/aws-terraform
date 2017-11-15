resource "aws_alb" "url_shortener" {
  name            = "url-shortener"
  security_groups = ["${aws_security_group.elb_default_sg.id}"]
  subnets         = ["${aws_subnet.url_shortener_1a.id}", "${aws_subnet.url_shortener_1b.id}"]
}

resource "aws_alb_target_group" "url_shortener" {
  name     = "url-shortener"
  protocol = "HTTP"
  port     = "5000"
  vpc_id   = "${aws_vpc.url_shortener.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
  }
}

resource "aws_alb_listener" "url_shortener" {
  load_balancer_arn = "${aws_alb.url_shortener.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.url_shortener.arn}"
    type             = "forward"
  }
}

#
# resource "aws_elb" "url_shortener" {
#     name = "url-shortener"
#     subnets = ["${aws_subnet.url_shortener_1a.id}", "${aws_subnet.url_shortener_1b.id}"]
#     connection_draining = true
#     cross_zone_load_balancing = true
#     security_groups = ["${aws_security_group.elb_default_sg.id}", "${aws_security_group.allow_cluster.id}"]
#
#     listener {
#         instance_port = 5000
#         instance_protocol = "http"
#         lb_port = 80
#         lb_protocol = "http"
#     }
#
#     health_check {
#         healthy_threshold = 2
#         unhealthy_threshold = 10
#         target = "HTTP:5000/"
#         interval = 5
#         timeout = 4
#     }
# }
