#build web server with bootstrap
provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web" {
  ami                    = "ami-00f22f6155d6d92c5" #amazon Linux 2 instance
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id] #create dependencies,
  #the resource aws_instance depends from the security group,
  #creating first the security group and next put the dependencies into aws_instance
  user_data = file("user_data.sh") #the function file is copiing data from necessary file
  tags = {
    Name  = "web server built by terraform"
    Owner = "a1500"
  }
}

resource "aws_security_group" "web" {
  name        = "web_server-SG"
  description = "access to my web server with the security group"

  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all ports"
    from_port   = 0 #0 means all ports
    to_port     = 0
    protocol    = "-1" #-1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "web server SG by terraform"
    Owner = "a1500"
  }
}
