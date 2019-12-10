# Route53 stuff

data "aws_route53_zone" "looker_r53_zone" {
  name = var.domain
}

resource "aws_route53_record" "looker_r53_record" {
  zone_id = data.aws_route53_zone.looker_r53_zone.zone_id
  type    = "CNAME"
  name    = var.subdomain
  records = ["${aws_lb.looker_lb.dns_name}"]
  ttl     = "30"
}
