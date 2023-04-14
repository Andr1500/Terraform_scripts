##############################
#  Provider
##############################

provider "aws" {
  region = var.region
}

##############################
#  VPC Configuration
##############################

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name                 = "3-instances"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

# Define the subnets for the EC2 instances
resource "aws_subnet" "public-subnet-1a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[0]
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "public-subnet-1b" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[1]
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "public-subnet-1b"
  }
}

resource "aws_subnet" "public-subnet-1c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[2]
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "public-subnet-1c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Public Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = {
    dev   = aws_subnet.public-subnet-1a.id,
    prod1 = aws_subnet.public-subnet-1b.id,
    prod2 = aws_subnet.public-subnet-1c.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

##############################
#  Network Security Groups
##############################

# ALB SG
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "alb-sg"
  vpc_id      = aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = [80, 81, 82]
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

# web SG
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "web-sg"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_security_group.alb-sg
  ]
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #here should be just 1 IP address
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EFS GS
resource "aws_security_group" "efs-sg" {
  name        = "efs-sg"
  description = "efs-sg"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_security_group.web-sg
  ]
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################
#  ALB and Target Groups
##############################

# Define the ALB and target groups
resource "aws_lb" "lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id, aws_subnet.public-subnet-1c.id]

}

# create a HTTP listener and redirection it to prod TG
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.prod-tg.arn
    redirect {
      port        = "81"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

# create a prod listener
resource "aws_alb_listener" "listener_prod" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 81
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod-tg.arn
  }
}

# create a dev listener
resource "aws_alb_listener" "listener_dev" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 82
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tg.arn
  }
}

# prod target group
resource "aws_lb_target_group" "prod-tg" {
  name        = "prod-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "prod-tg"
  }
  depends_on = [aws_lb.lb]
  lifecycle {
    create_before_destroy = true
  }
  load_balancing_algorithm_type = "round_robin"
}

# dev target group
resource "aws_lb_target_group" "dev-tg" {
  name        = "dev-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "dev-tg"
  }
  depends_on = [aws_lb.lb]
  lifecycle {
    create_before_destroy = true
  }
}

# Add instances to target groups
resource "aws_lb_target_group_attachment" "dev-1" {
  target_group_arn = aws_lb_target_group.dev-tg.arn
  target_id        = aws_instance.dev-1.id
  port             = 80
  depends_on       = [aws_instance.dev-1]
}

resource "aws_lb_target_group_attachment" "prod-1" {
  target_group_arn = aws_lb_target_group.prod-tg.arn
  target_id        = aws_instance.prod-1.id
  port             = 80
  depends_on       = [aws_instance.prod-1]
}

resource "aws_lb_target_group_attachment" "prod-2" {
  target_group_arn = aws_lb_target_group.prod-tg.arn
  target_id        = aws_instance.prod-2.id
  port             = 80
  depends_on       = [aws_instance.prod-2]
}

##############################
#  EFS Volume
##############################

# Define the EFS volume
resource "aws_efs_file_system" "efs_volume" {
  creation_token = "my-efs-volume"
}

resource "aws_efs_mount_target" "efs_mount1" {
  subnet_id       = aws_subnet.public-subnet-1b.id
  file_system_id  = aws_efs_file_system.efs_volume.id
  security_groups = [aws_security_group.efs-sg.id]
  depends_on = [
    aws_subnet.public-subnet-1b,
    aws_subnet.public-subnet-1c
  ]
}

resource "aws_efs_mount_target" "efs_mount2" {
  subnet_id       = aws_subnet.public-subnet-1c.id
  file_system_id  = aws_efs_file_system.efs_volume.id
  security_groups = [aws_security_group.efs-sg.id]
  depends_on = [
    aws_subnet.public-subnet-1b,
    aws_subnet.public-subnet-1c
  ]
}

##############################
#  Elastic IPs
##############################

# Elastic IPs
resource "aws_eip" "dev1" {
  vpc = true
}

resource "aws_eip" "prod1" {
  vpc = true
}

resource "aws_eip" "prod2" {
  vpc = true
}

# allocation Elastic IPs
resource "aws_eip_association" "dev1" {
  instance_id   = aws_instance.dev-1.id
  allocation_id = aws_eip.dev1.id
}

resource "aws_eip_association" "prod1" {
  instance_id   = aws_instance.prod-1.id
  allocation_id = aws_eip.prod1.id
}

resource "aws_eip_association" "prod2" {
  instance_id   = aws_instance.prod-2.id
  allocation_id = aws_eip.prod2.id
}

##############################
#  EC2 Instances
##############################

# Define the EC2 instances
resource "aws_instance" "dev-1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = "aws_key"
  subnet_id                   = aws_subnet.public-subnet-1a.id
  vpc_security_group_ids      = [aws_security_group.web-sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "dev-1"
  }
  user_data = templatefile("scripts/dev.tpl", {})
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }
}

resource "aws_instance" "prod-1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = "aws_key"
  subnet_id                   = aws_subnet.public-subnet-1b.id
  vpc_security_group_ids      = [aws_security_group.web-sg.id, aws_security_group.efs-sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "prod-1"
  }
  user_data = templatefile("scripts/prod.tpl", {
    ip_address = aws_efs_mount_target.efs_mount1.ip_address
  })
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }
}

resource "aws_instance" "prod-2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = "aws_key"
  subnet_id                   = aws_subnet.public-subnet-1c.id
  vpc_security_group_ids      = [aws_security_group.web-sg.id, aws_security_group.efs-sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "prod-2"
  }
  user_data = templatefile("scripts/prod.tpl", {
    ip_address = aws_efs_mount_target.efs_mount2.ip_address
  })
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }
}

