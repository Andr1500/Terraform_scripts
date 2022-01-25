provider "aws" {
  region = "eu-central-1"
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
  ami                    = data.aws_ami.latest_amazon_linux.id #amazon Linux 2 instance
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with PrivateIP: $MYIP</h2><br>Built by Terraform" > /var/www/html/index.html
echo "Server in the workspace: ${terraform.workspace}" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF

  tags = {
    Name  = "prod WEB server ${terraform.workspace}"
    Owner = "a1500"
  }
}

resource "aws_security_group" "web" {
  #  name        = "web_server-SG Prod"
  name_prefix = "Workspace"
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
    Name  = "web server SG by terraform ${terraform.workspace}"
    Owner = "a1500"
  }
}

resource "aws_eip" "web" { #Elastic IP attached to the machine
  instance = aws_instance.web.id
  tags = {
    Name  = "EIP for the web server built by terraform ${terraform.workspace}"
    Owner = "a1500"
  }
}
