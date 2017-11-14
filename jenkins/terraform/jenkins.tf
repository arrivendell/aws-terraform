provider "aws" {
  region     = "eu-west-1"
}

resource "aws_instance" "linux_server_16_04" {
  ami           = "ami-add175d4"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.allow_all_http.id}",
    "${aws_security_group.allow_ssh.id}"
  ]
  subnet_id = "${aws_subnet.jenkins_1c.id}"
  associate_public_ip_address = true
  key_name = "webinst"
}

resource "aws_vpc" "jenkins" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "jenkins_1c" {
  vpc_id     = "${aws_vpc.jenkins.id}"
  cidr_block = "172.31.16.0/20"
  availability_zone = "eu-west-1c"
}

resource "aws_subnet" "jenkins_1b" {
  vpc_id     = "${aws_vpc.jenkins.id}"
  cidr_block = "172.31.0.0/20"
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "jenkins_1a" {
  vpc_id     = "${aws_vpc.jenkins.id}"
  cidr_block = "172.31.32.0/20"
  availability_zone = "eu-west-1a"
}

resource "aws_internet_gateway" "gw_jenkins" {
  vpc_id = "${aws_vpc.jenkins.id}"
}

resource "aws_route" "internet" {
  route_table_id         = "${aws_vpc.jenkins.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw_jenkins.id}"
}

resource "aws_route_table_association" "jenkins_1a_association" {
    subnet_id = "${aws_subnet.jenkins_1a.id}"
    route_table_id = "${aws_vpc.jenkins.main_route_table_id}"
}

resource "aws_route_table_association" "jenkins_1b_association" {
    subnet_id = "${aws_subnet.jenkins_1b.id}"
    route_table_id = "${aws_vpc.jenkins.main_route_table_id}"
}

resource "aws_route_table_association" "jenkins_1c_association" {
    subnet_id = "${aws_subnet.jenkins_1c.id}"
    route_table_id = "${aws_vpc.jenkins.main_route_table_id}"
}

resource "aws_security_group" "allow_all_http" {
  name        = "allow_all_http"
  description = "Allow all inbound http-https traffic"
  vpc_id = "${aws_vpc.jenkins.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh from admin machine"
  vpc_id = "${aws_vpc.jenkins.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["80.217.171.180/32"]
  }
}


resource "aws_security_group" "allow_all_outbound" {
  name        = "allow_all_outbound"
  description = "Allow to reach the outside"
  vpc_id = "${aws_vpc.jenkins.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
