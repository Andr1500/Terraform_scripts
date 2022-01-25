provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "latest_ubuntu_server" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "latest_amazonlinux_server" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "latest_windows2019_server" {
  owners      = ["801119661308"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu_server.id
}

output "latest_amazonlinux_ami_id" {
  value = data.aws_ami.latest_amazonlinux_server.id
}

output "latest_windows_ami_id" {
  value = data.aws_ami.latest_windows2019_server.id
}

# ---------How to use
/*
resource "aws_instance" "server_ubuntu" {
  ami           = data.aws_ami.latest_ubuntu_server.id
  instance_type = "t3.micro"
}

resource "aws_instance" "server_amazon" {
  ami           = data.aws_ami.latest_amazonlinux.id
  instance_type = "t3.micro"
}
resource "aws_instance" "server_windows" {
  ami           = data.aws_ami.latest_windowserver2019.id
  instance_type = "t3.micro"
}
*/

#------------------
