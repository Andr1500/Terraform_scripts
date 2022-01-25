provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web" {
  ami                    = "ami-047e03b8591f2d48a" // Amazon Linux2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = templatefile("user_data.sh.tpl", { // Template File
    f_name = "Vasia"
    l_name = "Pupkin"
    names  = ["John", "Angel", "David", "Victor", "Frank", "Melissa", "Kitana", "Petro"]
  })

  tags = {
    Name  = "WebServer Built by Terraform"
    Owner = "a1500"
  }
}

resource "aws_security_group" "web" {
  name        = "WebServer-SG"
  description = "Security Group for my WebServer"

  ingress {
    description = "Allow port HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "WebServer SG by Terraform"
    Owner = "a1500"
  }
}

resource "aws_eip" "ip1" {}
resource "aws_eip" "ip2" {}
resource "aws_eip" "ip3" {}

output "web_ip_address" {
  value = aws_instance.web.public_ip
}

output "web_id" {
  value = aws_instance.web.id
}

output "web_security_group_id" {
  value = aws_security_group.web.id
}
