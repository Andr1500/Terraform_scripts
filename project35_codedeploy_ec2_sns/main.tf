provider "aws" {
  region = var.region
}

data "aws_ami" "rhel8" {
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL-8*HVM-*Hourly*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  owners = ["309956199498"] # Red Hat
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

#Create an IAM Policy
resource "aws_iam_policy" "EC2_codedeploy_policy" {
  name        = "EC2_codedeploy_policy"
  description = "Provides permission to access EC2 from Codedeploy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

#Create an IAM Role
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "codedeploy_attach" {
  name       = "codedeploy-attachment"
  roles      = [aws_iam_role.codedeploy_role.name]
  policy_arn = aws_iam_policy.EC2_codedeploy_policy.arn
}

resource "aws_iam_instance_profile" "codedeploy_profile" {
  name = "codedeploy_profile"
  role = aws_iam_role.codedeploy_role.name
}

#create IAM role for Codedeploy
resource "aws_iam_role" "CODEDEPLOY" {
  name = "Codedeploy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


#Attach policy AWSCodeDeployRole to CODEDEPLOY role
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.CODEDEPLOY.name
}

#Attach policy AWSCodeDeployRole to CODEDEPLOY role
resource "aws_iam_role_policy_attachment" "AmazonSNSFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role       = aws_iam_role.CODEDEPLOY.name
}

#Create Codedeploy application
resource "aws_codedeploy_app" "web" {
  name             = "web_app"
  compute_platform = "Server"
}

#Create SNS topic for notifications from CodeDeploy
resource "aws_sns_topic" "sns_topic" {
  name = "Codedeploy_sns_topic"
}

#Creation of SNS subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "a1500@tutanota.com"
}

#Create codedeploy deployment config
resource "aws_codedeploy_deployment_config" "codedeploy_config" {
  deployment_config_name = "CodeDeployDefault2.EC2AllAtOnce"

  #traffic_routing_config {
  #  type = "AllAtOnce"
  #}
  # Terraform: Should be "null" for EC2/Server

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }
}

#Create Codedeploy deployment group
resource "aws_codedeploy_deployment_group" "codedeploy_group" {
  app_name              = aws_codedeploy_app.web.name
  deployment_group_name = "codedeploy_group"
  # deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn = aws_iam_role.CODEDEPLOY.arn
  # deployment_style = "in-place"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Owner"
      type  = "KEY_AND_VALUE"
      value = "Gtlab_CI"
    }
  }

  trigger_configuration {
    trigger_events = ["DeploymentFailure", "DeploymentSuccess", "DeploymentStop",
    "InstanceStart", "InstanceSuccess", "InstanceFailure"]
    trigger_name       = "event-trigger"
    trigger_target_arn = aws_sns_topic.sns_topic.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }

  # deployment_style {
  #   deployment_option = "WITH_TRAFFIC_CONTROL"
  #   deployment_type   = "IN_PLACE"
  # }
}

resource "aws_codecommit_repository" "code" {
  repository_name = "code-repo"
}

#policy for SNS topic
data "aws_iam_policy_document" "notif_access" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }
    resources = [aws_sns_topic.sns_topic.arn]
  }
}

#sns notification policy
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.notif_access.json
}

#Notification rule
resource "aws_codestarnotifications_notification_rule" "commits" {
  detail_type    = "BASIC"
  event_type_ids = ["codedeploy-application-deployment-failed", "codedeploy-application-deployment-succeeded"]

  name     = "codedeploy_commits"
  resource = aws_codedeploy_deployment_group.codedeploy_group.arn

  target {
    address = aws_sns_topic.sns_topic.arn
  }
}

resource "aws_instance" "RHEL8" {
  count                  = var.count_rhel_instances
  ami                    = data.aws_ami.rhel8.id
  instance_type          = var.instance_type
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.codedeploy_profile.name

  tags = {
    Name  = "Server_RHEL8_${count.index + 1}"
    Owner = "Gitlab_CI"
  }

  provisioner "file" {
    destination = "/tmp/docker_aws_install_rhel.sh"
    content = templatefile("docker_aws_install_rhel.sh.tpl", {
      default_region = "${var.region}"
    })
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/docker_aws_install_rhel.sh",
      "sudo /tmp/docker_aws_install_rhel.sh"
    ]
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
  }
}

resource "aws_instance" "ubuntu_linux" {
  count                  = var.count_ubuntu_instances
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.codedeploy_profile.name

  provisioner "file" {
    destination = "/tmp/docker_aws_install_ubuntu.sh"
    content = templatefile("docker_aws_install_ubuntu.sh.tpl", {
      default_region = "${var.region}"
    })
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/docker_aws_install_ubuntu.sh",
      "sudo /tmp/docker_aws_install_ubuntu.sh"
    ]
  }
  tags = {
    Name  = "Server_Ubuntu_Linux_${count.index + 1}"
    Owner = "Gtlab_CI"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }
}

resource "aws_security_group" "sg" {
  name = "SG"

  dynamic "ingress" {
    for_each = ["80", "8080", "443", "22", "5000"]
    content {
      description = "Allow port HTTP"
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
}
