# Application Load Balancer

resource "aws_lb_target_group" "looker_lb_tg" {
  name     = "${var.prefix}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  
  health_check {
    port      = 80
    protocol  = "HTTP"
    path      = "/alive"
  }

  tags = {
    Name            = "${var.prefix}_lb_tg"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_lb" "looker_lb" {
  depends_on          = ["aws_security_group.looker_lb","aws_s3_bucket.s3_looker_access_log_bucket"]

  name                = "${var.prefix}-alb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = ["${aws_security_group.looker_lb.id}"]
  subnets             = ["${var.public_subnet1_id}", "${var.public_subnet2_id}"]
  
  access_logs {
    bucket  = "${aws_s3_bucket.s3_looker_access_log_bucket.id}"
    prefix  = "looker-lb"
    enabled = true
  }

  tags = {
    Name            = "${var.prefix}_alb"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_lb_listener" "looker_lb_listener" {
  depends_on        = ["aws_lb.looker_lb","aws_acm_certificate_validation.cert","aws_lb_target_group.looker_lb_tg"]

  load_balancer_arn = "${aws_lb.looker_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate_validation.cert.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.looker_lb_tg.arn}"
  }
}
