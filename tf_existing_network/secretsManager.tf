provider "random" {
  version = "~> 2.1"
}

# Random password and Secrets Manager

resource "random_string" "looker_rds_password" {
  length  = 30
  special = false
}

resource "aws_secretsmanager_secret" "looker_sm_secret" {
  name                    = "${var.prefix}_looker_user_password"
  recovery_window_in_days = 0 # make this configurable

  tags = {
    Name            = "${var.prefix}_looker_sm_secret"
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }
}

resource "aws_secretsmanager_secret_version" "looker_sm_secret_version" {
  secret_id     = aws_secretsmanager_secret.looker_sm_secret.id
  secret_string = random_string.looker_rds_password.result
}
