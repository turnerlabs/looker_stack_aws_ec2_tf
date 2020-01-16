variable "region" {
  description = "Region"
  default     = "us-east-1"
}

variable "profile" {
  description = "Profile from credentials"
  default     = "default"
}

variable "tag_name" {}
variable "tag_application" {}
variable "tag_contact_email" {}
variable "tag_customer" {}
variable "tag_team" {}
variable "tag_environment" {}

variable "vpc_id" {
  description = "VPC to launch looker in"
}

variable "private_subnet1_id" {
  description = "Private Subnet to put instances in"
}

variable "private_subnet2_id" {
  description = "Private Subnet to put datastores in"
}

variable "public_subnet1_id" {
  description = "Public Subnet to put load balancer in"
}

variable "public_subnet2_id" {
  description = "Public Subnet"
}

variable "prefix" {
  description = "Name to prefix all the items with"
}

variable "looker_bastion_ami" {
  description = "looker Bastion AMI created by packer"
}

variable "looker_backup_ami" {
  description = "looker Backup AMI created by packer"
}

variable "looker_node_ami" {
  description = "looker Webserver / Scheduler AMI created by packer"
}

variable "looker_node_instance_class" {
  description = "looker instance size"
  default     = "m3.medium" 
}

variable "backup_node_instance_class" {
  description = "backup instance size"
  default     = "t3.small" 
}

variable "looker_keypair_name" {
  description = "AWS keypair to use on the looker ec2 instance"
}

variable "db_identifier" {
  description = "Database identifier"
  default     = "looker-rds"
}

variable "db_port" {
  description = "Database port"
  default     = "3306"
}

variable "db_use_ssl" {
  description = "Use SSL for Database connectivity"
  default     = "true"
}

variable "db_master_username" {
  description = "MySQL master username"
  default     = "admin"
}

variable "db_master_password" {}

variable "db_looker_username" {
  description = "MySQL looker username"
  default     = "looker"
}

variable "db_looker_dbname" {
  description = "MYSQL looker database name"
  default     = "looker_db"
}

variable "db_engine_version" {
  description = "MYSQL looker engine version"
  default     = "5.7.16"
}

variable "db_instance_class" {
  description = "MYSQL looker instance class"
  default     = "db.m5.large"
}

variable "db_cert" {
  description = "Certificate for RDS server"
  default     = "rds-ca-2019"
}


variable "s3_looker_bucket_name"  {
  description = "looker bucket for looker shared directory"
}

variable "s3_looker_backup_bucket_name"  {
  description = "looker bucket for looker backups"
}

variable "s3_looker_access_log_bucket_name"  {
  description = "looker bucket for alb access logs"
}

variable "waf_ip"  {
  description = "instance ingress ip to allow"
}

variable "waf_looker_support_ip"  {
  description = "instance ingress ip to allow"
  default ="54.209.194.236/32"
}

variable "ingress_ips"  {
  description = "instance ingress ip to allow"
}

variable "ingress_ip_description"  {
  description = "instance ingress ip description"
}

variable "aws_account_number" {
  description = "AWS account number"  
}

variable "domain" {
  description = "Domain for Route53"  
}

variable "subdomain" {
  description = "Sub Domain for cert"
}

variable "alb_accesslog_account" {
  description="Look here for more info: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions"
  default="127311923021"
}

variable "secret_recovery_window_in_days" {
  description="How many days to keep a secret before deleting it.  0 is immediately"
  default="0"
}

variable "notification_email" {
  description="This email will receive sns notification from any resources that alarm.  It is required"
}

variable "efs_mount_point" {
  description="Security group for looker"
  default="/mnt/lookerfiles"
}

variable "node_listener_port" {
  description="Node listener port for looker nodes"
  default="9999"
}

variable "node_to_node_port" {
  description="Node to node communication port for looker nodes"
  default="1551"
}

variable "queue_broker_port" {
  description="Queue broker port for looker node"
  default="61616"
}

variable "scheduler_threads" {
  description="Number of simultaneous scheduled tasks"
  default="20"
}

variable "unlimited_scheduler_threads" {
  description="Number of simultaneous unlimited scheduled tasks"
  default="15"
}

variable "scheduler_query_limit" {
  description="Limits number of concurrent scheduled queries"
  default="30"
}

variable "per_user_query_limit" {
  description="Limits number of concurrent queries per user"
  default="40"
}

variable "scheduler_query_timeout" {
  description="Length of scheduler timeout to wait for connection"
  default="3600"
}
