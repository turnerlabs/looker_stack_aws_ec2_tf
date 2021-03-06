resource "aws_iam_user_policy" "iam_user_policy" {
  name = "${var.prefix}_looker_backup"
  user = aws_iam_user.iam_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_looker_backup_bucket.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_looker_backup_bucket.arn}/*"
            ]

        }
    ]
}
EOF
}

resource "aws_iam_user" "iam_user" {
  force_destroy = true
  name          = "srv_backup_looker_${var.prefix}"

  tags = {
    Name          = "${var.prefix}_looker_iam_user"
    application   = var.tag_application
    contact-email = var.tag_contact_email
    customer      = var.tag_customer
    team          = var.tag_team
    environment   = var.tag_environment
  }
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}