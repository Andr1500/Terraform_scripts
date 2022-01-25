provider "aws" {
  region = "eu-central-1"
}

resource "aws_iam_user" "user" {
  for_each = toset(var.aws_users)
  name     = each.value
}

resource "aws_instance" "server1" {
  count         = 4
  ami           = "ami-06ec8443c2a35b0ba"
  instance_type = "t3.micro"
  tags = {
    Name  = "server ${count.index + 1}"
    Owner = "a1500"
  }
}
