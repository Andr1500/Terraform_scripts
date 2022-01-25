provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "server_web" {
  ami                    = "ami-00f22f6155d6d92c5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.aws_group.id]

  depends_on = [
    aws_instance.server_DB,
    aws_instance.server_app
  ]
  tags = { Name = "Server WEB" }
}

resource "aws_instance" "server_app" {
  ami                    = "ami-00f22f6155d6d92c5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.aws_group.id]

  depends_on = [aws_instance.server_DB]
  tags       = { Name = "Server APP" }
}

resource "aws_instance" "server_DB" {
  ami                    = "ami-00f22f6155d6d92c5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.aws_group.id]
  tags                   = { Name = "Server DB" }
}

resource "aws_security_group" "aws_group" {
  name = "my-security-group"

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      description = "allow http"
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

  tags = {
    Name = "My SecurityGroup"
  }
}
