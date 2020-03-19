# Backup Instance Related Items
# Using an lc / asg to have backup instance come up and run once a day.
resource "aws_launch_configuration" "lc_backup" {
  name                        = "${var.prefix}_lc_backup"
  associate_public_ip_address = false
  image_id                    = var.looker_backup_ami
  instance_type               = var.backup_node_instance_class
  key_name                    = var.looker_keypair_name
  security_groups             = ["${aws_security_group.looker_instance.id}"]
  user_data_base64            = base64encode(templatefile("${path.cwd}/templates/backup-user-data.tpl", { s3_looker_backup_bucket_name = "${aws_s3_bucket.s3_looker_backup_bucket.id}", efs_dns_name = aws_efs_file_system.looker_clustered_efs.dns_name }))
  iam_instance_profile        = aws_iam_instance_profile.looker_s3_instance_profile.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "asg_backup" {
  name                      = "${var.prefix}_asg_backup"
  vpc_zone_identifier       = [var.private_subnet1_id, var.private_subnet2_id]
  launch_configuration      = aws_launch_configuration.lc_backup.id
  max_size                  = "0"
  min_size                  = "0"
  desired_capacity          = "0"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.prefix}_backup_node"
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

resource "aws_autoscaling_schedule" "asg_schedule_backup_start" {
  scheduled_action_name  = "backup_efs_start"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "00 02 * * 1-7" #On at 10PM EST
  autoscaling_group_name = aws_autoscaling_group.asg_backup.name
}

resource "aws_autoscaling_schedule" "asg_schedule_backup_finish" {
  scheduled_action_name  = "backup_efs_finish"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "00 03 * * 1-7" #Off at 11PM EST
  autoscaling_group_name = aws_autoscaling_group.asg_backup.name
}
