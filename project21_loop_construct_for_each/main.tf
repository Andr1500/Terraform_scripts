provider "aws" {
  region = "eu-central-1"
}

resource "aws_iam_user" "user" {
  for_each = toset(var.aws_users)
  #toset is terrform function convert list value to a set
  name = each.value
}


resource "aws_instance" "servers" {
  for_each      = toset(["stag", "prod"])
  ami           = "ami-07df274a488ca9195"
  instance_type = "t3.micro"
  tags = {
    Name  = "Server: ${each.value}"
    Owner = "a1500"
  }
}

#creating instances with atribute loop
resource "aws_instance" "server" {
  for_each      = var.server_settings
  ami           = each.value["ami"]
  instance_type = each.value["instance_type"]

  root_block_device {
    volume_size = each.value["root_disk_size"]
    encrypted   = each.value["encrypted"]
  }
  volume_tags = {
    Name = "Disk: ${each.key}"
  }
  tags = {
    Name  = "server: ${each.key}"
    Owner = "a1500"
  }
}

resource "aws_instance" "bastionServer" {
  for_each      = var.create_bastion_server == "yes" ? toset(["bastion"]) : []
  ami           = "ami-0453cb7b5f2b7fca2"
  instance_type = "t3.micro"
  tags = {
    Name  = "server bastion"
    Owner = "a1500"
  }
}
