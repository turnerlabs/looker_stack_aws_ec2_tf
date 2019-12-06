output "github_action_access_key_id" {
  value = "${aws_iam_access_key.iam_access_key.id}"
}

output "github_action_access_key_secret" {
  value = "${aws_iam_access_key.iam_access_key.secret}"
}
