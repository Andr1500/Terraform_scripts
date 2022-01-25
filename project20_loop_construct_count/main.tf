provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "serverLinux" {
  count         = 3 #for creating necessary number of the servers
  ami           = "ami-0453cb7b5f2b7fca2"
  instance_type = "t3.micro"
  tags = {
    Name  = "server Number ${count.index + 1}"
    Owner = "a1500"
  }
}

resource "aws_iam_user" "user" {
  count = length(var.aws_users)
  name  = element(var.aws_users, count.index)
  #function element retrieves a single element from a list.
}

resource "aws_instance" "bastionServer" {
  count         = var.create_bastion == "yes" ? 1 : 0
  ami           = "ami-0453cb7b5f2b7fca2"
  instance_type = "t3.micro"
  tags = {
    Name  = "server bastion"
    Owner = "a1500"
  }
}
