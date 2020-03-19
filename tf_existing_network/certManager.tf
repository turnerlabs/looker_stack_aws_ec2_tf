# Certificate Manager Stuff

resource "aws_acm_certificate" "looker_acm_cert" {
  domain_name       = var.subdomain
  validation_method = "DNS"

  tags = {
    Name          = "${var.prefix}_looker_acm_cert"
    application   = var.tag_application
    contact-email = var.tag_contact_email
    customer      = var.tag_customer
    team          = var.tag_team
    environment   = var.tag_environment
  }
}

resource "aws_route53_record" "looker_r53_cert_record" {
  name    = aws_acm_certificate.looker_acm_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.looker_acm_cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.looker_r53_zone.id
  records = ["${aws_acm_certificate.looker_acm_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.looker_acm_cert.arn
  validation_record_fqdns = ["${aws_route53_record.looker_r53_cert_record.fqdn}"]
}
