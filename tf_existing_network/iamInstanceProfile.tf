# IAM Role

resource "aws_iam_role" "looker_instance" {

  name = format("%s_instance", var.prefix)

  tags = {
    Name          = "${var.prefix}_looker_iam_role"
    application   = var.tag_application
    contact-email = var.tag_contact_email
    customer      = var.tag_customer
    team          = var.tag_team
    environment   = var.tag_environment
  }

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
  name = "${var.prefix}_s3"
  role = aws_iam_role.looker_instance.name

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
              "${aws_s3_bucket.s3_looker_backup_bucket.arn}"
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
              "${aws_s3_bucket.s3_looker_backup_bucket.arn}/*"
            ]
        }

    ]
}
EOF
}

# IAM Logs Role Policy

resource "aws_iam_role_policy" "looker_logs" {
  name = "${var.prefix}_logs"
  role = aws_iam_role.looker_instance.name

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
  name = "${var.prefix}_secrets"
  role = aws_iam_role.looker_instance.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": "${aws_secretsmanager_secret.looker_sm_secret.id}"
      }
   ]
}
EOF
}


# IAM EFS Role Policy

resource "aws_iam_role_policy" "looker_efs" {
  name = "${var.prefix}_efs"
  role = aws_iam_role.looker_instance.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid" : "Stmt1CreateMountTargetAndTag",
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateMountTarget",
        "elasticfilesystem:DescribeMountTargets",
        "elasticfilesystem:CreateTags",
        "elasticfilesystem:DescribeTags"
      ],
      "Resource": "${aws_efs_file_system.looker_clustered_efs.arn}"
    },
    {
      "Sid" : "Stmt2AdditionalEC2PermissionsToCreateMountTarget",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSubnets",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


# IAM Instance Profile

resource "aws_iam_instance_profile" "looker_s3_instance_profile" {
  name = "${var.prefix}_instance_profile"
  role = aws_iam_role.looker_instance.name
}

# SSM Policy for cloudwatch logs

resource "aws_iam_role_policy_attachment" "looker_ssm_managed_policy_attachment" {
  role       = aws_iam_role.looker_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
