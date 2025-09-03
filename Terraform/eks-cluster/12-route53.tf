## route 53
resource "aws_route53_zone" "my-route53" {
  name = "beatoncloud.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my-route53.zone_id
  name    = "www"
  type    = "A"
  #ttl = "300"
  alias {
    name    = aws_lb.my_alb.dns_name
    zone_id = aws_lb.my_alb.zone_id

    evaluate_target_health = true
  }
}
