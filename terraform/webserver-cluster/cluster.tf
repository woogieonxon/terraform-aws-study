# vi cluster.tf

##보안그룹
resource "aws_security_group" "webserver_sg" {
  name   = "webserver-sg"
  vpc_id = aws_vpc.my_vpc.id

  # Ingress rules
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pub_sub_1.cidr_block, aws_subnet.pub_sub_2.cidr_block]
  }
}


##오토스케일링
resource "aws_launch_template" "webserver_template" {

  # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  image_id               = "ami-09a7535106fbd42d5"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data              = base64encode("#!/bin/bash\necho \"Hello, World\" > index.html\nnohup busybox httpd -f -p ${var.server_port} &\n")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "template"
    }
  }
}

resource "aws_autoscaling_group" "webserver_asg" {
  vpc_zone_identifier = [aws_subnet.prv_sub_1.id, aws_subnet.prv_sub_2.id]

  target_group_arns = [aws_lb_target_group.target_asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 3

  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = "$Latest" # 항상 최신 버전 시작 템플릿 사용
  }

  depends_on = [
    aws_vpc.my_vpc,
    aws_subnet.prv_sub_1,
    aws_subnet.prv_sub_2
  ]
}

##로드밸런서
resource "aws_security_group" "alb_sg" {
  name   = var.alb_security_group_name
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "webserver_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "target_asg" {
  name     = var.alb_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webserver_alb.arn
  port              = var.server_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_asg.arn
  }
}

resource "aws_lb_listener_rule" "webserver_asg_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_asg.arn
  }
}
