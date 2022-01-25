provider "aws" {
  region = "eu-central-1"
}


terraform { #to store data to remote state
  backend "s3" {
    bucket = "a1500-terraform-remote-state" #bucket for terraform state file (save information)
    key    = "dev/web/terraform.tfstate"    #remote path of the file
    region = "eu-central-1"                 #region where the bucket is created
  }
}

#using as source for networks file from other layer (network)
data "terraform_remote_state" "vpc" { #to use data from remote state
  backend = "s3"
  config = {
    bucket = "a1500-terraform-remote-state"  #bucket for terraform state file (get information)
    key    = "dev/network/terraform.tfstate" #remote path of the file
    region = "eu-central-1"                  #region where the bucket is created
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.latest_amazon_linux.id # Amazon Linux2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with PrivateIP: $MYIP</h2><br>Built by Terraform" > /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF
  tags = {
    Name  = "${var.env}-Webserver"
    Owner = "a1500"
  }
}

resource "aws_security_group" "web" {
  name        = "WebServer-SG"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Security Group for my WebServer"

  ingress {
    description = "Allow port HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr] #allowed to ssh only from our network
  }

  egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.env}-web-server-sg"
    Owner = "a1500"
  }
}
