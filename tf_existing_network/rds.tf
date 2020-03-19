# RDS Related Items

resource "aws_db_subnet_group" "looker_rds_subnet_grp" {
  subnet_ids = ["${var.private_subnet1_id}", "${var.private_subnet2_id}"]

  tags = {
    Name          = "${var.prefix}_rds"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}

# resource "aws_db_parameter_group" "looker_rds_parameter_grp" {
#   name   = "${var.prefix}-looker-rds-parameter-grp"
#   family = "mysql5.7"

#   parameter {
#     name = "max_allowed_packet"
#     value = "1073741824"
#   }

#   parameter {
#     name = "character_set_client"
#     value = "utf8mb4"
#   }

#   parameter {
#     name = "character_set_results"
#     value = "utf8mb4"
#   }

#   parameter {
#     name = "character_set_connection"
#     value = "utf8mb4"
#   }

#   parameter {
#     name = "character_set_database"
#     value = "utf8mb4"
#   }

#   parameter {
#     name = "character_set_server"
#     value = "utf8mb4"
#   }

#   parameter {
#     name = "collation_connection"
#     value = "utf8mb4_general_ci"
#   }

#   parameter {
#     name = "collation_server"
#     value = "utf8mb4_general_ci"
#   }

# }

resource "aws_db_instance" "looker_rds" {
  allocated_storage                   = 150
  allow_major_version_upgrade         = false
  auto_minor_version_upgrade          = true
  backup_retention_period             = 7
  backup_window                       = "00:00-01:30"
  copy_tags_to_snapshot               = true
  db_subnet_group_name                = aws_db_subnet_group.looker_rds_subnet_grp.id
  deletion_protection                 = true
  engine                              = "mysql"
  engine_version                      = var.db_engine_version
  iam_database_authentication_enabled = false
  identifier                          = "${var.prefix}-${var.db_identifier}-instance"
  instance_class                      = var.db_instance_class
  max_allocated_storage               = 1000
  multi_az                            = true
  parameter_group_name                = var.db_parameter_group_name
  password                            = var.db_master_password
  port                                = var.db_port
  publicly_accessible                 = false
  skip_final_snapshot                 = "true"
  storage_type                        = "gp2"
  username                            = var.db_master_username
  vpc_security_group_ids              = ["${aws_security_group.looker_rds.id}"]
  ca_cert_identifier                  = "rds-ca-2019"
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.looker_rds_kms_key.arn

  tags = {
    Name          = "${var.prefix}-${var.db_identifier}"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}
