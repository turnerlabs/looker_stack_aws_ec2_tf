# WAF

resource "aws_wafregional_ipset" "looker_waf_ipset" {
  name = "${var.prefix}_looker_waf_ipset"

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_ip1
  }

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_ip2
  }

  ip_set_descriptor {
    type  = "IPV4"
    value = var.waf_looker_support_ip
  }
}

resource "aws_wafregional_rule" "looker_waf_rule" {
  name        = "${var.prefix}_waf_rule"
  metric_name = "${var.prefix}wafrule"

  tags = {
    application   = var.tag_application
    contact-email = var.tag_contact_email
    customer      = var.tag_customer
    team          = var.tag_team
    environment   = var.tag_environment
  }

  predicate {
    data_id = aws_wafregional_ipset.looker_waf_ipset.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "looker_waf_web_acl" {
  name        = "${var.prefix}_looker_waf_web_acl"
  metric_name = "${var.prefix}lookerwafwebacl"

  tags = {
    application   = var.tag_application
    contact-email = var.tag_contact_email
    customer      = var.tag_customer
    team          = var.tag_team
    environment   = var.tag_environment
  }

  default_action {
    type = "BLOCK"
  }
  rule {
    action {
      type = "ALLOW"
    }
    priority = 1
    rule_id  = aws_wafregional_rule.looker_waf_rule.id
  }
}

resource "aws_wafregional_web_acl_association" "looker_waf_web_acl_assoc" {
  resource_arn = aws_lb.looker_lb.arn
  web_acl_id   = aws_wafregional_web_acl.looker_waf_web_acl.id
}
