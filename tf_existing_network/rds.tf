# RDS Related Items

resource "aws_db_subnet_group" "looker_rds_subnet_grp" {
  subnet_ids = ["${var.private_subnet1_id}", "${var.private_subnet2_id}"]

  tags = {
    Name            = "${var.prefix}_rds"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# resource "aws_db_parameter_group" "looker_rds_parameter_grp" {
#   name   = "${var.prefix}-looker-rds-parameter-grp"
#   family = "mysql5.7"

#   parameter {
#     name = "binlog_cache_size"
#     value = "32768"
#   }

#   parameter {
#     name = "binlog_format"
#     value = "MIXED"
#   }

#   parameter {
#     name = "character_set_database"
#     value = "utf8"
#   }

#   parameter {
#     name = "character_set_server"
#     value = "utf8"
#   }

#   parameter {
#     name = "collation_connection"
#     value = "utf8_general_ci"
#   }

#   parameter {
#     name = "collation_server"
#     value = "utf8_general_ci"
#   }

#   parameter {
#     name = "default_storage_engine"
#     value = "InnoDB"
#   }

#   parameter {
#     name = "explicit_defaults_for_timestamp"
#     value = "1"
#   }

#   parameter {
#     name = "gtid-mode"
#     value = "OFF_PERMISSIVE"
#   }

#   parameter {
#     name = "innodb_file_per_table"
#     value = "1"
#   }

#   parameter {
#     name = "innodb_flush_method"
#     value = "O_DIRECT"
#   }

#   parameter {
#     name = "innodb_log_buffer_size"
#     value = "8388608"
#   }

#   parameter {
#     name = "innodb_log_file_size"
#     value = "134217728"
#   }

#   parameter {
#     name = "key_buffer_size"
#     value = "16777216"
#   }

#   parameter {
#     name = "local_infile"
#     value = "1"
#   }

#   parameter {
#     name = "log_output"
#     value = "TABLE"
#   }

#   parameter {
#     name = "master-info-repository"
#     value = "TABLE"
#   }

#   parameter {
#     name = "max_allowed_packet"
#     value = "1073741824"
#   }

#   parameter {
#     name = "max_binlog_size"
#     value = "134217728"
#   }

#   parameter {
#     name = "performance_schema"
#     value = "0"
#   }

#   parameter {
#     name = "query_cache_size"
#     value = "18000000"
#   }

#   parameter {
#     name = "query_cache_type"
#     value = "0"
#   }

#   parameter {
#     name = "read_buffer_size"
#     value = "262144"
#   }

#   parameter {
#     name = "read_rnd_buffer_size"
#     value = "524288"
#   }

#   parameter {
#     name = "relay_log_info_repository"
#     value = "TABLE"
#   }

#   parameter {
#     name = "relay_log_recovery"
#     value = "1"
#   }

#   parameter {
#     name = "slow_query_log"
#     value = "1"
#   }

#   parameter {
#     name = "sql_mode"
#     value = "NO_ENGINE_SUBSTITUTION"
#   }

#   parameter {
#     name = "sync_binlog"
#     value = "1"
#   }

#   parameter {
#     name = "table_open_cache_instances"
#     value = "16"
#   }

#   parameter {
#     name = "thread_stack"
#     value = "262144"
#   }
# }

resource "aws_db_instance" "looker_rds" {
  allocated_storage                     = 150
  allow_major_version_upgrade           = false
  auto_minor_version_upgrade            = true
  backup_retention_period               = 7
  backup_window                         = "00:00-01:30"
  copy_tags_to_snapshot                 = true
  db_subnet_group_name                  = aws_db_subnet_group.looker_rds_subnet_grp.id
  deletion_protection                   = true
  engine                                = "mysql"
  engine_version                        = var.db_engine_version
  iam_database_authentication_enabled   = false
  identifier                            = "${var.prefix}-${var.db_identifier}-instance"
  instance_class                        = var.db_instance_class
  max_allocated_storage                 = 1000
  multi_az                              = true
  parameter_group_name                  = "default.mysql5.7"
  password                              = var.db_master_password
  port                                  = var.db_port
  publicly_accessible                   = false
  skip_final_snapshot                   = "false"
  storage_type                          = "gp2"
  storage_encrypted                     = true
  username                              = var.db_master_username
  vpc_security_group_ids                = ["${aws_security_group.looker_rds.id}"]
  ca_cert_identifier                    = "rds-ca-2019"  # this is hardcoded because it's broken in the 2.44.0 version on the AWS provider.


  tags = {
    Name            = "${var.prefix}-${var.db_identifier}"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}
