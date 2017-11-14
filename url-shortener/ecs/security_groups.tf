resource "aws_security_group" "elb_default_sg" {
    name        = "elb_default_sg"
    description = "Allowing HTTP in for elbs and all out"
    vpc_id = "${aws_vpc.url_shortener.id}"


    // HTTP
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
}
resource "aws_security_group" "instances_default_sg" {
    name        = "instances_default_sg"
    description = "Allowing HTTP custom app port and SSH from adriens host for instances behind elb"
    vpc_id = "${aws_vpc.url_shortener.id}"


    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups  = ["${aws_security_group.elb_default_sg.id}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["80.217.171.180/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "allow_cluster" {
    name_prefix = "${aws_vpc.url_shortener.id}-"
    description = "Allow all traffic within cluster"
    vpc_id = "${aws_vpc.url_shortener.id}"

    ingress = {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    egress = {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }
}
