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

variable "availability_zone_1" {
  description = "az 1 of 2 azs"
  default     = "us-east-1c"
}

variable "availability_zone_2" {
  description = "az 2 of 2 azs"
  default     = "us-east-1d"
}
variable "looker_bastion_ami" {
  description = "looker Bastion AMI created by packer"
}

variable "looker_node_ami" {
  description = "looker Webserver / Scheduler AMI created by packer"
}

variable "looker_node_instance_class" {
  description = "looker instance size"
  default     = "m4.xlarge"
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
  default     = "looker"
}

variable "db_engine_version" {
  description = "MYSQL looker engine version"
  default     = "5.7.16"
}

variable "db_instance_class" {
  description = "MYSQL looker instance class"
  default     = "db.m5.2xlarge"
}

variable "looker_username" {
  description = "looker username for website access"
  default     = "looker"
}

variable "looker_emailaddress" {
  description = "looker emailaddress for website access"
}

variable "looker_password"  {
  description = "looker password for website access"
}

variable "looker_first"  {
  description = "looker users first name for website access"
}

variable "looker_last"  {
  description = "looker users last name for website access"
}

variable "looker_role"  {
  description = "looker users role for website access. Roles can be Admin, User, Op, Viewer, and Public"
}

variable "s3_looker_bucket_name"  {
  description = "looker bucket for looker shared directory"
}

variable "s3_looker_log_bucket_name"  {
  description = "looker bucket for looker logs"
}

variable "s3_looker_access_log_bucket_name"  {
  description = "looker bucket for alb access logs"
}

variable "waf_ip"  {
  description = "instance ingress ip to allow"
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

variable "looker_efs_security_group_id" {
  description="Security group for looker"
}

variable "efs-subnet-mount1" {
  description="Subnet to mount efs in 1"
}

variable "efs-subnet-mount2" {
  description="Subnet to mount efs in 2"
}
