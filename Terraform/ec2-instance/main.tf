provider "aws" {
  region = "ap-northeast-2"
}

# Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
resource "aws_instance" "EC2_Instance" {
  ami           = "ami-09a7535106fbd42d5"
  instance_type = "t2.micro"

  tags = {
    Name = "EC2_Instance"
  }
}
