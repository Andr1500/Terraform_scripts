provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "ubuntu_machine" { #creating ubuntu server
  ami           = "ami-05f7491af5eef733a"
  instance_type = "t3.micro"
  key_name      = "terraform_login"

  tags = {
    Name    = "My_Ubuntu_Server"
    Owner   = "a1500"
    Project = "Lion_Phish"
  }
}

resource "aws_instance" "aws_machine" { #creating Amazon linux server
  ami           = "ami-00f22f6155d6d92c5"
  instance_type = "t3.small"

  tags = {
    Name  = "My_AWS_Server_linux"
    Owner = "a1500"
  }
}
