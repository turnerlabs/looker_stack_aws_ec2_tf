output "backup_access_key_id" {
  value = "${aws_iam_access_key.iam_access_key.id}"
}

output "backup_access_key_secret" {
  value = "${aws_iam_access_key.iam_access_key.secret}"
}

output "backup_bucket_name" {
  value = "${aws_s3_bucket.s3_looker_backup_bucket.id}"
}

output "backup_bucket_region" {
  value = "${aws_s3_bucket.s3_looker_backup_bucket.region}"
}
