#create security groups with dynamic blocks
provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web" {
  name        = "web_server-SG"
  description = "creating the the security group"

  dynamic "ingress" { #creating dynamic block
    for_each = ["3200", "8080", "443", "2020", "2021"]
    content {
      description = "allow ports"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  ingress {
    description = "allow http"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.168.12.0/24"]
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
