provider "aws" {
  region     = "eu-west-1"
}

resource "aws_instance" "linux_server_16_04" {
  ami           = "ami-add175d4"
  instance_type = "t2.micro"
}
