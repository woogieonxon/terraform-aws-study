# ALB 
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_was_alb_sg.id]
  subnets            = [aws_subnet.Private_was_subnet_a.id, aws_subnet.Private_was_subnet_c.id]
  tags = {
    "Name" = "my-alb"
  }
}

output "dns_name" {
  value = "aws_lb.my_alb.dns_name"
}

# 대상그룹 설정
resource "aws_lb_target_group" "my_albtg" {
  name     = "my-albtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 5
    matcher             = "200"
    path                = "/health.html"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 2
    unhealthy_threshold = 3
  }
}

# 로드밸런서 EC2 연결
resource "aws_lb_target_group_attachment" "attachment_ec2" {
  target_group_arn = aws_lb_target_group.my_albtg.arn
  target_id        = aws_instance.my_bastion_ec2.id
  port             = 80
}

## 리스너 추가
# 리스너
resource "aws_lb_listener" "my_alblis" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
    target_group_arn = aws_lb_target_group.my_albtg.arn
  }
}

# 로드밸런서 규칙 추가
resource "aws_lb_listener_rule" "my-rule" {
  listener_arn = aws_lb_listener.my_alblis.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_albtg.arn
  }
  condition {
    host_header {
      values = ["www.beatoncloud.com"]
    }
  }
}
