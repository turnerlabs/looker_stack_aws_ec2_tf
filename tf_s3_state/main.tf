terraform {
  required_version = ">=0.12.19"
}

provider "aws" {
  version = "~> 2.44.0"
  region  = var.region
  profile = var.profile
}
# create an s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = "true"

  versioning {
    enabled = var.versioning
  }

  tags = {
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}
