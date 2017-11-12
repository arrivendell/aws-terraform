provider "aws" {
  region     = "eu-west-1"
}

resource "aws_route53_zone" "arrivendel" {
  name = "arrivendel.com"
}

resource "aws_route53_zone" "url" {
  name = "url.arrivendel.com"

  tags {
    Environment = "url"
  }
}

resource "aws_route53_record" "url-ns" {
  zone_id = "${aws_route53_zone.arrivendel.zone_id}"
  name    = "url.arrivendel.com"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.url.name_servers.0}",
    "${aws_route53_zone.url.name_servers.1}",
    "${aws_route53_zone.url.name_servers.2}",
    "${aws_route53_zone.url.name_servers.3}",
  ]
}
