data "aws_iam_policy_document" "assume_by_ecs" {
  statement {
    sid     = "AllowAssumeByEcsTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid    = "AllowECRLogging"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_role" {
  statement {
    sid    = "AllowDescribeCluster"
    effect = "Allow"

    actions = ["ecs:DescribeClusters"]

    resources = ["${aws_ecs_cluster.ecs_cluster.arn}"]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.service_name}_ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "execution_role" {
  name   = "${var.service_name}_ecs_exec_policy"
  role   = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role" "task_role" {
  name               = "${var.service_name}_ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "task_role" {
  name   = "${var.service_name}_ecs_task_policy"
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role.json
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.service_name}_cluster"
}

resource "aws_security_group" "ecs" {
  name   = "${var.service_name}-allow-ecs"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description     = "Ingress"
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    description = "Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
