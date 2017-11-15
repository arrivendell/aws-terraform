resource "aws_internet_gateway" "gw_url_shortener" {
  vpc_id = "${aws_vpc.url_shortener.id}"
}

resource "aws_route" "internet" {
  route_table_id         = "${aws_vpc.url_shortener.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw_url_shortener.id}"
}

resource "aws_route_table_association" "url_shortener_1a_association" {
  subnet_id      = "${aws_subnet.url_shortener_1a.id}"
  route_table_id = "${aws_vpc.url_shortener.main_route_table_id}"
}

resource "aws_route_table_association" "url_shortener_1b_association" {
  subnet_id      = "${aws_subnet.url_shortener_1b.id}"
  route_table_id = "${aws_vpc.url_shortener.main_route_table_id}"
}

# Could add a network-acl config
