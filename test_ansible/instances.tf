#This script is creatng necessary servers with the necessary OS (Ubuntu or CentOS)
#for Ansible work. SSH keys added during creation and we need only correct inventory file.
#
# For using ssh keys in this script we need to do:
#
# 1. Go to the necessary dir and generate keys:
# ssh-keygen -t rsa -b 2048
#
# 2. Upload the public into AWS console -> Key Pairs:
# AWS console -> Key Pairs -> Actions -> Import key pair ->
#   ->(put the name "aws_key" and download the key) -> Import


provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "ansible_amazon_linux" {
  count                  = 2
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  #user_data              = templatefile("hosts.tpl", { backend_ip = aws_instance.ansible[*].public_ip })

  tags = {
    Name  = "Server_Amazon_Linux_${count.index + 1}"
    Owner = "a1500"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("/home/a1500/ansible/keys/aws_key")
  }
}

resource "aws_instance" "ansible_ubuntu_linux" {
  count                  = 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro" #for ELK is necessary t2.medium
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  #user_data              = templatefile("hosts.tpl", { backend_ip = aws_instance.ansible[*].public_ip })

  tags = {
    Name  = "Server_Ubuntu_Linux_${count.index + 1}"
    Owner = "a1500"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("/home/a1500/ansible/keys/aws_key")
  }
}

resource "aws_security_group" "ansible_sg" {
  name = "ansible-SG"

  dynamic "ingress" {
    for_each = ["80", "8080", "443", "22", "8200", "9200", "5601", "5044", "3000"]
    content {
      description = "Allow port HTTP"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "local_file" "private_ips" {
  filename = "/home/a1500/ansible/hosts.txt"
  #content  = join("\n", "${aws_instance.ansible[*].tags.Name})
  content = join("\n", "${aws_instance.ansible_amazon_linux[*].public_ip}", "${aws_instance.ansible_ubuntu_linux[*].public_ip}")
}
