resource "aws_instance" "web-prod" {
  ami                    = data.aws_ami.latest_amazon_linux.id #amazon Linux 2 instance
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web-prod.id]
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
    Name  = "prod WEB server"
    Owner = "a1500"
  }
}

resource "aws_security_group" "web-prod" {
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
    Name  = "web server SG prod"
    Owner = "a1500"
  }
}
