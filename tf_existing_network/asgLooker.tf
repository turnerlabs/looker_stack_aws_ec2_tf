# Looker Instance Related Items
# Using an lc / asg to keep looker up and running.
resource "aws_launch_configuration" "lc_looker" {
  name                        = "${var.prefix}_lc_looker"
  associate_public_ip_address = false
  image_id                    = var.looker_node_ami
  instance_type               = var.looker_node_instance_class
  key_name                    = var.looker_keypair_name
  security_groups             = ["${aws_security_group.looker_instance.id}"]
  user_data_base64            = base64encode(templatefile("${path.cwd}/templates/looker-user-data.tpl", {s3_looker_bucket_name = "${aws_s3_bucket.s3_looker_bucket.id}",db_region = var.region, looker_secret = "${aws_secretsmanager_secret.looker_sm_secret.id}", rds_url = "${aws_db_instance.looker_rds.address}", db_master_username = var.db_master_username, db_master_password = var.db_master_password, db_looker_username = var.db_looker_username, db_looker_password = random_string.looker_rds_password.result, db_looker_dbname = var.db_looker_dbname, db_port = var.db_port, db_use_ssl = var.db_use_ssl, node_listener_port = var.node_listener_port, node_to_node_port = var.node_to_node_port, queue_broker_port = var.queue_broker_port, efs_mount_point = var.efs_mount_point, efs_dns_name = aws_efs_file_system.looker_clustered_efs.dns_name, scheduler_threads = var.scheduler_threads, unlimited_scheduler_threads = var.unlimited_scheduler_threads, scheduler_query_limit = var.scheduler_query_limit, per_user_query_limit = var.per_user_query_limit, scheduler_query_timeout = var.scheduler_query_timeout}))  
  iam_instance_profile        = aws_iam_instance_profile.looker_s3_instance_profile.id

  root_block_device {
    volume_type                 = "gp2"
    volume_size                 = 8
    encrypted                   = true
    delete_on_termination       = true
  }
}

resource "aws_autoscaling_group" "asg_looker" {
  name                      = "${var.prefix}_asg_looker"
  vpc_zone_identifier       = [var.private_subnet1_id, var.private_subnet2_id]  
  launch_configuration      = aws_launch_configuration.lc_looker.id
  max_size                  = "5"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]
  target_group_arns         = ["${aws_lb_target_group.looker_lb_tg.arn}"]

  tag {
    key                 = "Name"
    value               = "${var.prefix}_looker_node"
    propagate_at_launch = true
  }

  tag {
    key                 = "application"
    value               = var.tag_application
    propagate_at_launch = true
  }

  tag {
    key                 = "contact-email"
    value               = var.tag_contact_email
    propagate_at_launch = true
  }

  tag {
    key                 = "customer"
    value               = var.tag_customer
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = var.tag_team
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = var.tag_environment
    propagate_at_launch = true
  }
}
