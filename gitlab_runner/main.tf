#############################
#  Provider config
#############################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # Set your desired region
}

#############################
# SSH key
#############################

# Creation of ssh key:
# ssh-keygen -t rsa -b 4096 -f gitlab_runner

# Variable for ssh dir.
variable "ssh_dir" {
  type    = string
  default = "~/.ssh"
}

# Read the public key from the local SSH directory
data "local_file" "public_key" {
  filename = "${pathexpand(var.ssh_dir)}/gitlab_runner.pub"
}

# Create the key pair in AWS
resource "aws_key_pair" "ssh_key" {
  key_name   = "gitlab-runner-ssh-key"
  public_key = data.local_file.public_key.content
}

#############################
# ASG
#############################

data "aws_vpc" "default" {
  default = true
}

output "vpc" {
  value = data.aws_vpc.default.id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

}

output "subnetid" {
  value = data.aws_subnets.default.ids

}

# take Ubuntu AMI image for the instances
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# default registration_token variable
variable "registration_token" {
  type    = string
  default = "some_token"
}

data "template_file" "config_runner" {
  template = file("config_runner.tpl")
  vars = {
    registration_token = var.registration_token
  }
}

# ec2 instance launch template. Here we use launch template instead of launch configuration 
# because of LC deprecation https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-lc-with-instanceID.html
resource "aws_launch_template" "launch_template" {
  name_prefix            = "gitlab-runner-launch-template"
  image_id               = data.aws_ami.ubuntu.id # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.gitlab-runner-sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2profile.name
  }
  user_data = base64encode(data.template_file.config_runner.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "gitlab-runner-shell-executor"
    }
  }
}

# Create an Auto Scaling Group using the Launch Configuration
resource "aws_autoscaling_group" "asg" {
  name = "gitlab-runner-asg"
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [data.aws_subnets.default.ids[0], data.aws_subnets.default.ids[1]]
  depends_on = [
    aws_launch_template.launch_template
  ]
}

#############################
#  NSG
#############################

# Create a security group for the instances
resource "aws_security_group" "gitlab-runner-sg" {
  name        = "gitlab-runner-sg"
  description = "gitlab-runner-sg"
  vpc_id      = data.aws_vpc.default.id
  dynamic "ingress" {
    for_each = [22, 2376]
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#############################
#  IAM
#############################

# Create an IAM instance profile for the instances
resource "aws_iam_instance_profile" "ec2profile" {
  name = "gitlab-runner-instance-profile"

  role = aws_iam_role.gitlab-runner-role.name
}

# Create an IAM role for the instances
resource "aws_iam_role" "gitlab-runner-role" {
  name = "gitlab-runner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
        }
      }
    ]
  })
}

# policy attachments
variable "aws_managed_policies" {
  type = list(string)
  default = [
    "AmazonEC2FullAccess",
    "AmazonS3FullAccess",
    "AmazonVPCFullAccess",
    "AmazonElasticFileSystemFullAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "gitlab_runner_role_policy_attachments" {
  count      = length(var.aws_managed_policies)
  policy_arn = "arn:aws:iam::aws:policy/${var.aws_managed_policies[count.index]}"
  role       = aws_iam_role.gitlab-runner-role.name
}

