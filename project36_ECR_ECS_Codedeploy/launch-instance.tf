data "aws_ami" "latest-ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_launch_configuration" "launch_config" {
  name                 = "ECS-Instance-${var.service_name}"
  image_id             = data.aws_ami.latest-ecs.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 15
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.ecs.id}", "${aws_security_group.alb.id}"]
  associate_public_ip_address = "true"
  key_name                    = var.ecs_key_pair_name
  user_data = templatefile("ec2_user_data.tpl", {
    service_name = var.service_name
  })
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.service_name}-ecs-autoscaling-group"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = aws_subnet.public.*.id
  launch_configuration = aws_launch_configuration.launch_config.name
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "ECS-Instance-${var.service_name}-service"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "${var.service_name}-ecs-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "${var.service_name}-ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-instance-role.id
}
