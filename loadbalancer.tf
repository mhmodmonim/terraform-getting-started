# aws_elb_service_account
data "aws_elb_service_account" "root" {}

# create aws_lb
resource "aws_lb" "nginx-alb" {
  name                       = "alula-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for sb in aws_subnet.public_subnets : sb.id]
  depends_on                 = [aws_s3_bucket_policy.allow_access_from_another_account]
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.s3.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}

#create alb target groups
resource "aws_lb_target_group" "nginx" {
  name     = "nginx-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id
  tags     = local.common_tags
}

#create ALB Lisnter
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
  tags = local.common_tags
}

#create target group instance attachments

resource "aws_lb_target_group_attachment" "attach_nginx_instances" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx_instances[count.index].id
  port             = 80
}