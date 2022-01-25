provider "aws" {
  region = "eu-central-1"
}

data "aws_region" "current" {}

resource "aws_instance" "server1" {
  ami                    = var.ami_id_per_region[data.aws_region.current.name]
  instance_type          = lookup(var.server_size, var.env, var.server_size["my_default"])
  vpc_security_group_ids = [aws_security_group.server1.id]

  root_block_device {
    volume_size = 10
    encrypted   = (var.env == "prod") ? true : false #conditional
  }

  dynamic "ebs_block_device" { #for creating block conditional
    for_each = var.env == "prod" ? [true] : []
    content {
      device_name = "/dev/sdb"
      volume_size = 40
      encrypted   = true
    }
  }

  volume_tags = { Name = "Disk ${var.env}" }
  tags        = { Name = "Server ${var.env}" }
}

resource "aws_security_group" "server1" {
  name = "my server security group"

  dynamic "ingress" {
    for_each = lookup(var.allow_port, var.env, var.allow_port["rest"])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "my server dynamic SG"
    Owner = "a1500"
  }
}
