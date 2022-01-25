module "global_variables" {
  source = "../global_vars"
}

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

resource "aws_instance" "web" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = module.global_variables.prod_server_size
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>${var.server_name}-WebServer with IP: $myip</h2><br>Build by Terraform Cloud!"  >  /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF

  tags = merge({
    Name = "${var.server_name}-WebServer"
  Owner = "a1500" }, module.global_variables.tags)

}

resource "aws_security_group" "web" {
  name_prefix = "${var.server_name}-WebServer-SG"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]



  }

  tags = merge({
    Name = "${var.server_name}-WebServer SecurityGroup"
  Owner = "a1500" }, module.global_variables.tags)

}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  tags = merge({
    Name = "${var.server_name}-WebServer-IP"
  Owner = "a1500" }, module.global_variables.tags)

}
