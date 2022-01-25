provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "server1" {
  ami           = "ami-06ec8443c2a35b0ba"
  instance_type = "t3.micro"
  tags = {
    Name  = "server1"
    Owner = "a1500"
  }
}

resource "aws_instance" "server2" {
  ami           = "ami-06ec8443c2a35b0ba"
  instance_type = "t3.micro"
  tags = {
    Name  = "server2"
    Owner = "a1500"
  }
}

resource "aws_instance" "server3" {
  ami           = "ami-06ec8443c2a35b0ba"
  instance_type = "t3.micro"
  tags = {
    Name  = "server3"
    Owner = "a1500"
  }
  depends_on = [aws_instance.server2]
}
