provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "for_each_map" {
  for_each = {
    woogie = {
      Team  = "woogie"
      Login = "False"
      Key   = "True"
    }

    woogin = {
      Team  = "woogin"
      Login = "True"
      Key   = "True"
    }

    woori = {
      Team  = "woori"
      Login = "True"
      Key   = "True"
    }

    wooju = {
      Team  = "wooju"
      Login = "True"
      Key   = "True"
    }
  }

  name = each.key
  tags = each.value
}

output "for_each_map_user_arns" {
  value = values(aws_iam_user.for_each_map).*.arn
}
