# All things EFS

resource "aws_efs_file_system" "looker_clustered_efs" {
  creation_token    = "looker_clustered_efs"
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

resource "aws_efs_mount_target" "looker_clustered_efs_mount1" {
  file_system_id  = "${aws_efs_file_system.looker_clustered_efs.id}"
  subnet_id       = "${var.private_subnet1_id}"
  security_groups = [ "${aws_security_group.looker_efs.id}" ]
}
resource "aws_efs_mount_target" "looker_clustered_efs_mount2" {
  file_system_id  = "${aws_efs_file_system.looker_clustered_efs.id}"
  subnet_id       = "${var.private_subnet2_id}"
  security_groups = [ "${aws_security_group.looker_efs.id}" ]
}
