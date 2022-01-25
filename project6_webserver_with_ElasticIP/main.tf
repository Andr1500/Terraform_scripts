#build web server with bootstrap with external template file
provider "aws" {
  region = "eu-central-1"
}

resource "aws_eip" "web" { #Elastic IP attached to the machine
  instance = aws_instance.web.id
  tags = {
    Name  = "EIP for the web server built by terraform"
    Owner = "a1500"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-00f22f6155d6d92c5" #amazon Linux 2 instance
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id] #create dependencies,
  #the resource aws_instance depends from the security group,
  #creating first the security group and next put the dependencies into aws_instance
  user_data = file("user_data.sh")
  tags = {
    Name  = "web server built by terraform"
    Owner = "a1500"
  }

  lifecycle { #parameter for minimum downtime
    create_before_destroy = true
  }
}

resource "aws_security_group" "web" {
  name        = "web_server-SG"
  description = "access to my web server with the security group"

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      description = "allow http"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
