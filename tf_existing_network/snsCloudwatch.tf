# AWS SNS Email

resource "aws_sns_topic" "looker_sns_notifications" {
  name = "looker_sns_notifications"

  tags = {
    Name            = "${var.prefix}_looker_sns_notif"
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.looker_sns_notifications.arn} --protocol email --notification-endpoint ${var.notification_email}"
  }
}

# looker Cloudwatch Resource Monitors

# RDS MySQL(CPU, Free Storage, and Disk Queue) - connections vary by db type so that's not a good alarm.

resource "aws_cloudwatch_metric_alarm" "looker_rds_cpu_utilization_too_high" {
  alarm_name          = "${var.prefix}_looker_rds_cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average RDS CPU utilization has been over 80% for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.looker_sns_notifications.arn}"]

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  dimensions = {
    DBInstanceIdentifier = "${aws_db_instance.looker_rds.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "looker_rds_free_storage_space_too_low" {
  alarm_name          = "${var.prefix}_looker_rds_free_storage_space_threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "2000000000"
  alarm_description   = "Average RDS free storage space has been less than 2 gigabyte for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.looker_sns_notifications.arn}"]

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  dimensions = {
    DBInstanceIdentifier = "${aws_db_instance.looker_rds.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "looker_rds_disk_queue_depth_too_high" {
  alarm_name          = "${var.prefix}_looker_rds_disk_queue_depth_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "64"
  alarm_description   = "Average RDS disk queue depth has been over 64 for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.looker_sns_notifications.arn}"]

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  dimensions = {
    DBInstanceIdentifier = "${aws_db_instance.looker_rds.id}"
  }
}

# ASG on Looker Node(CPUUtilization)

resource "aws_cloudwatch_metric_alarm" "looker_asg_looker_cpu_utilization_too_high" {
  alarm_name          = "${var.prefix}_looker_asg_cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Average Looker Autoscale Group CPU Utilization has been over 80% for the last 10 minutes."
  alarm_actions       = ["${aws_sns_topic.looker_sns_notifications.arn}"]

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_looker.id}"
  }
}

# WAF(Blocked Requests)

resource "aws_cloudwatch_metric_alarm" "looker_waf_blocked_requests" {
  alarm_name          = "${var.prefix}_looker_waf_blocked_requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "WAF"
  period              = "600"
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description   = "Sum WAF Blocked Request Count has been over 1000 for the last 10 minutes"
  alarm_actions       = ["${aws_sns_topic.looker_sns_notifications.arn}"]

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  dimensions = {
    WebACL  = "${aws_wafregional_web_acl.looker_waf_web_acl.id}"
    Region  = "${var.region}"
    Rule    = "${aws_wafregional_rule.looker_waf_rule.id}"
  }
}