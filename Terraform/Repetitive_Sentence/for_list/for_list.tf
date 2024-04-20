provider "aws" {
  region = "ap-northeast-2"
}

variable "names" {
  type    = list(string)
  default = ["woori", "woogin", "wooju", "woogie"]
}

output "names" {
  value = [for name in var.names : upper(name)]
}
