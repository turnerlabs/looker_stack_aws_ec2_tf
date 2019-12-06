# All things EFS

resource "aws_efs_file_system" "looker-clustered-efs" {
  creation_token    = "looker-clustered-efs"
  encrypted         = true

  tags = {
    Name            = "${var.prefix}_looker_clustered_efs"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_efs_mount_target" "looker-clustered-efs-mount1" {
  file_system_id  = "${aws_efs_file_system.looker-clustered-efs.id}"
  subnet_id       = "${var.efs-subnet-mount1}"
  security_groups = [ "${var.looker_efs_security_group_id}" ]
}
resource "aws_efs_mount_target" "looker-clustered-efs-mount2" {
  file_system_id  = "${aws_efs_file_system.looker-clustered-efs.id}"
  subnet_id       = "${var.efs-subnet-mount2}"
  security_groups = [ "${var.looker_efs_security_group_id}" ]
}
