# IAM Role

resource "aws_iam_role" "looker_instance" {

  name = "${var.prefix}_instance"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM S3 Role Policy

resource "aws_iam_role_policy" "looker_s3" {
  depends_on  = ["aws_iam_role.looker_instance"]

  name = "${var.prefix}_s3"
  role = "${aws_iam_role.looker_instance.name}"

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
              "${aws_s3_bucket.s3_looker_bucket.arn}",
              "${aws_s3_bucket.s3_looker_log_bucket.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_looker_bucket.arn}/*",
              "${aws_s3_bucket.s3_looker_log_bucket.arn}/*"
            ]
        }

    ]
}
EOF
}

# IAM Logs Role Policy

resource "aws_iam_role_policy" "looker_logs" {
  depends_on  = ["aws_iam_role.looker_instance"]

  name = "${var.prefix}_logs"
  role = "${aws_iam_role.looker_instance.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          "arn:aws:logs:*:*:*"
        ]
      }
   ]
}
EOF
}

# IAM Secrets Manager Role Policy

resource "aws_iam_role_policy" "looker_secrets" {
  depends_on  = ["aws_iam_role.looker_instance"]

  name = "${var.prefix}_secrets"
  role = "${aws_iam_role.looker_instance.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": [
          "${aws_secretsmanager_secret.looker_sm_secret.id}"
        ]
      }
   ]
}
EOF
}


# IAM Instance Profile

resource "aws_iam_instance_profile" "looker_s3_instance_profile" {
  depends_on  = ["aws_iam_role.looker_instance", "aws_iam_role_policy.looker_s3", "aws_iam_role_policy.looker_logs"]
  
  name = "${var.prefix}_instance_profile"
  role = "${aws_iam_role.looker_instance.name}"
}

# SSM Policy for cloudwatch logs

resource "aws_iam_role_policy_attachment" "looker_ssm_managed_policy_attachment" {
  role = "${aws_iam_role.looker_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
