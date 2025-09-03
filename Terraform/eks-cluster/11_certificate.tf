## 인증서 요청
resource "aws_acm_certificate" "cert" {
  domain_name       = "beatoncloud.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}
