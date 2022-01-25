provider "aws" {
  region = "eu-central-1"
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform START $(date) >> file1.txt"
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 4 www.cisco.com"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    interpreter = ["python", "-c"]
    command     = "print ('version 3.8 of python')"
  }
}

resource "null_resource" "command4" {
  provisioner "local-exec" {
    command = "echo $name1 $name2 $name3 >> file1.txt"
    environment = {
      name1 = "Mark",
      name2 = "Vasia",
      name3 = "Petia",
      name4 = "Natan",
    }
  }
}

resource "aws_instance" "server" {
  ami           = "ami-06ec8443c2a35b0ba"
  instance_type = "t3.micro"
  provisioner "local-exec" {
    command = "echo ${aws_instance.server.private_ip} >> file1.txt"
  }
}

resource "null_resource" "command5" {
  provisioner "local-exec" {
    command = "echo terraform finish : $(date) >> file1.txt"
  }
  depends_on = [
    null_resource.command1,
    null_resource.command2,
    null_resource.command3,
    null_resource.command4,
    aws_instance.server
  ]
}
