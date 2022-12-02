locals {
  target_groups = ["BLUE", "GREEN"]
}

#ALB security group
resource "aws_security_group" "alb" {
  name   = "${var.service_name}-allow-http"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = ["80", "443", "22", "5000"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-allow-http"
  }
}

# application load balanser
resource "aws_lb" "front" {
  name               = "${var.service_name}-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = aws_subnet.public.*.id

  tags = {
    Name = "${var.service_name}-service-alb"
  }
}

# ALB target group
resource "aws_lb_target_group" "target_group" {
  count = length(local.target_groups)
  name  = "${var.service_name}-tg-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    path = "/"
  }
}

#HTTPS ALB listener
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.front.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn
  default_action {
    target_group_arn = aws_lb_target_group.target_group.0.arn
    type             = "forward"
  }
}

# HTTP ALB listener
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.target_group.0.arn
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# get existing certificate data from ACM
data "aws_acm_certificate" "issued" {
  domain   = "*.${var.route53_hosted_zone_name}"
  statuses = ["ISSUED"]
}

# get data about DNS zone ID
data "aws_route53_zone" "zone" {
  name = var.route53_hosted_zone_name
}

# Route 53 A record
resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.route53_subdomain_name}.${var.route53_hosted_zone_name}"
  type    = "A"
  alias {
    name                   = aws_lb.front.dns_name
    zone_id                = aws_lb.front.zone_id
    evaluate_target_health = true
  }
}

# resource "aws_lb_listener_rule" "this" {
#   # count        = 2
#   listener_arn = aws_lb_listener.listener_https.arn
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this.0.arn
#   }
#
#   condition {
#     host_header {
#       values = ["flaskapp.an1500.click"]
#     }
#   }
# }
