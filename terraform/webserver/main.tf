provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      Name = "Webserver"
    }
  }
}

variable "webserver_port" {
  description = "Webserver HTTP Port"
  default = 8080
}

resource "aws_security_group" "Webserver_sg" {
  name = "Webserver_sg"
  ingress {
    from_port   = var.webserver_port
    to_port     = var.webserver_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
resource "aws_instance" "Webserver" {
  ami                    = "ami-09a7535106fbd42d5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Webserver_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.webserver_port} &
    EOF
}

output "public_ip" {
  value = aws_instance.Webserver.public_ip
}

output "instance_type" {
  value = aws_instance.Webserver.instance_type
}