provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "for_each_set" {
  for_each = toset(["woori", "woogin", "wooju", "woogie"])
  name     = each.key
}

output "for_each_set_user_arns" {

  value = values(aws_iam_user.for_each_set).*.arn

}