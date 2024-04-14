# vi cluster.tf 
resource "aws_security_group" "webserver_sg" {
  name   = "webserver_sg"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = var.webserver_port
    to_port     = var.webserver_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "egress security_group_rule for web"
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }
  tags = {
    Name = "webserver_sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = var.webserver_port
    to_port     = var.webserver_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "egress security_group_rule for alb"
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }
  tags = {
    Name = "alb_sg"
  }
}

# Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
resource "aws_instance" "webserver" {
  ami                    = "ami-09a7535106fbd42d5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  subnet_id              = aws_subnet.Subnet-Private-Web-A.id

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.webserver_port} &
    EOF
  tags = {
    Name = "webserver"
  }
}




resource "aws_ami_from_instance" "webserver_ami" {
  name               = "webserver_ami"
  source_instance_id = aws_instance.webserver.id

}

resource "aws_launch_template" "webserver_template" {
  image_id               = aws_ami_from_instance.webserver_ami.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data = base64encode("#!/bin/bash\necho \"Hello, World\" > index.html\nnohup busybox httpd -f -p ${var.webserver_port} &\n")


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webserver_template"
    }
  }
}

resource "aws_autoscaling_group" "my_asg" {
  name                = "autoscaling-group"
  vpc_zone_identifier = [aws_subnet.Subnet-Private-Web-A.id, aws_subnet.Subnet-Private-Web-C.id]
  target_group_arns   = [aws_lb_target_group.webserver_tg.arn]
  health_check_type   = "ELB"
  depends_on          = [aws_vpc.my_vpc, aws_subnet.Subnet-Private-Web-A, aws_subnet.Subnet-Private-Web-C]
  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = "$Latest"
  }
  min_size = 2
  max_size = 3
}

resource "aws_lb" "webserver_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = [aws_subnet.Subnet-Public-A.id, aws_subnet.Subnet-Public-C.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "webserver_tg" {
  name     = var.alb_name
  port     = var.webserver_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 50
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webserver_alb.arn
  port              = var.webserver_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver_tg.arn
  }
}

resource "aws_lb_listener_rule" "asg_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver_tg.arn
  }
}


