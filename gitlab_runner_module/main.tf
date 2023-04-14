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

module "gitlab-runner-scale_example_public_webhook" {
  source  = "cmdlabs/gitlab-runner-scale/aws//examples/public_webhook"
  version = "0.4.0"
}

module "gitlab-runner" {
  source  = "cmdlabs/gitlab-runner-scale/aws//examples/public_webhook"
  version = "0.4.0"

  asg = {
    associate_public_ip_address = true
    instance_type               = "t3.micro"
    job_policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances",
                "ssm:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
    max_size                    = 1
    min_size                    = 0
    spot_price                  = "0.0100"
    subnet_ids                  = ["0d1a1676985362da0", "subnet-xxx", "subnet-xxx"]
  }

  gitlab = {
    api_token_ssm_path                 = "/gitlab/api_token"
    log_level                          = "debug"
    runner_agents_per_instance         = 1
    runner_registration_token_ssm_path = "/gitlab/runner_registration_token"
    uri                                = "https://gitlab.com/"
  }

  lambda = {
    memory_size = 128
    rate        = "rate(1 minute)"
    runtime     = "python3.8"
  }
}
