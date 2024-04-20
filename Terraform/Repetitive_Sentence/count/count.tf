provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "count_user" {
  count = 4

  name = "WOOGIE-${count.index}"
}

output "count_user_name" {

  value = aws_iam_user.count_user[*].name
}