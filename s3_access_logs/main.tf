provider "aws" {
  region = "eu-central-1"
}

variable "access_logs" {
  type = map(string)
  default = {
    bucket = "1234567-lkjhgfd"
    prefix = ""
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "1234567-lkjhgfd"
  # acl           = "log-delivery-write"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::1234567-lkjhgfd/AWSLogs/AWSLogs/account_id/*",
    ]
    actions = ["s3:PutObject"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789:root"]
    }
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::1234567-lkjhgfd/AWSLogs/AWSLogs/account_id/*",
    ]
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elb.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::1234567-lkjhgfd/AWSLogs/AWSLogs/account_id/*",
    ]
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elb.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket     = aws_s3_bucket.this.id
  policy     = data.aws_iam_policy_document.s3_bucket_lb_write.json
  depends_on = [aws_s3_bucket.this]
}

resource "aws_lb" "this" {
  name               = "alb01"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0fed38232e58c1b3c"]
  subnets            = ["subnet-0d1a1676985362da0", "subnet-0648d49dfc571a867"]

  access_logs {
    bucket  = aws_s3_bucket.this.bucket
    prefix  = "AWSLogs"
    enabled = true
  }
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
