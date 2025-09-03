provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "ec2_is_type" {
  count = var.instance_count

  # 변경하고자 하는 AMI ID로 수정
  ami = "ami-09a7535106fbd42d5"
  instance_type = var.environment[
  count.index % length(var.environment)] == "Production" ? "t2.large" : "t2.micro"

  tags = {
    environment = var.environment[
    count.index % length(var.environment)]
  }
}