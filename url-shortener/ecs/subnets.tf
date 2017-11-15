resource "aws_subnet" "url_shortener_1c" {
  vpc_id            = "${aws_vpc.url_shortener.id}"
  cidr_block        = "172.31.16.0/20"
  availability_zone = "eu-west-1c"
}

resource "aws_subnet" "url_shortener_1b" {
  vpc_id            = "${aws_vpc.url_shortener.id}"
  cidr_block        = "172.31.0.0/20"
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "url_shortener_1a" {
  vpc_id            = "${aws_vpc.url_shortener.id}"
  cidr_block        = "172.31.32.0/20"
  availability_zone = "eu-west-1a"
}
