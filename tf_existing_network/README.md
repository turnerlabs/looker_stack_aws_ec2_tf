# Description

This is a [terraform](https://www.terraform.io/) script to create a complete Looker stack excluding networking(assume a direct connnected setup).

You will need to update the terraform state bucket in the main.tf file.  This should have already been created in the tf_s3_state directory.

It creates the following resources in AWS:

- 1 ALB for Webserver
- 1 WAF
- 1 Subdomain created in Route53
- 1 SSL cert is created using ACM
- 1 Secret Manager key is created for access from the Looker Node instance(s) to the RDS instance.
- 1 MySQL RDS database using MultiAZ
- 2 Security groups
  - 1 for RDS access
  - 1 for Looker instance access
- 1 Launch Config using Looker Node AMI
- 1 Auto Scale Group for Looker Node
- 1 EC2 Bastion Server

The Looker instances will be able to communicate with each other as well as RDS MySQL.

#### Assumptions

* You have run samlkeygen (or an alternative method) to generate secret / access keys for the AWS account.
* An Amazon SSH Key Pair(pem file) has already been created.
* A domain has been registered in Route53 with a hosted zone.

#### Notes

* Each resource was broken into it's own terraform file.  So efs.tf has the efs resources and rds.tf has the rds resources.  

* I won't get into the details of each resource but you can take a look at the terraform AWS provider [here](https://www.terraform.io/docs/providers/aws/index.html) for more information on the paramters for each resource.

* The main.tf file containing all the common things like what version of the aws provider is required and the version of terraform that's required.

* The tpl files contain the user-data scripts for the ec2 resources in auto scale groups.

* Please check the variables.tf for a clear description of what each variable is that is passed to this terraform.

```bash
terraform init
```

```bash
terraform apply
-var 'tag_name=<>'
-var 'tag_application=<>'
-var 'tag_team=<>'
-var 'tag_environment=<>'
-var 'tag_contact_email=<>'
-var 'tag_customer=<>'
-var 'db_identifier=<>'
-var 'looker_keypair_name=<>'
-var 'db_master_username=<>'
-var 'db_master_password=<>'
-var 'db_looker_username=<>'
-var 'db_looker_password=<>'
-var 'looker_username=<>'
-var 'looker_emailaddress=<>'
-var 'looker_password=<>'
-var 'looker_first=<>'
-var 'looker_last=<>'
-var 's3_looker_bucket_name=<>'
-var 's3_looker_access_log_bucket_name=<>'
-var 's3_looker_log_bucket_name=<>'
-var 'ingress_ips=<>'
-var 'ingress_ip_description=<>'
-var 'aws_account_number=<>'
-var 'looker_node_ami=<>'
-var 'prefix=<>'
-var 'domain=<>'
-var 'subdomain=<>'
```

All the variables that are defaulted

```bash
variable "tag_application" {}
variable "tag_contact_email" {}
variable "tag_customer" {}
variable "tag_team" {}
variable "tag_environment" {}

variable "prefix" {
  description = "Name to prefix all the resources with"
}

variable "looker_node_ami" {
  description = "looker Webserver / Scheduler AMI created by packer"
}

variable "looker_node_instance_class" {
  description = "Looker Node instance size"
  default     = "t3.medium"
}

variable "looker_keypair_name" {
  description = "AWS keypair to use on the looker ec2 instances.  They will need to be rotated."
}

variable "db_identifier" {
  description = "Database identifier"
  default     = "looker_rds"
}

variable "db_port" {
  description = "Database port"
  default     = "3306"
}

variable "db_master_username" {
  description = "MySQL master username"
  default     = "admin"
}

variable "db_master_password" {}

variable "db_looker_username" {
  description = "MySQL Looker username"
  default     = "looker"
}

variable "db_looker_password" {}

variable "db_looker_dbname" {
  description = "MYSQL looker database name"
  default     = "looker"
}

variable "db_engine_version" {
  description = "MYSQL looker engine version"
  default     = "8.0"
}

variable "db_instance_class" {
  description = "MYSQL looker instance class"
  default     = "db.t2.small"
}

variable "db_parameter_group_name" {
  description = "MYSQL looker parameter group"
  default     = "default.mysql8.0"
}

variable "db_charset" {
  description = "MYSQL looker database character set"
  default     = "latin1"
}

variable "looker_username" {
  description = "Looker username for website access"
  default     = "looker"
}

variable "looker_emailaddress" {
  description = "Looker emailaddress for website access"
}

variable "looker_password"  {
  description = "Looker password for website access"
}

variable "looker_first"  {
  description = "Looker users first name for website access"
}

variable "looker_last"  {
  description = "Looker users last name for website access"
}

variable "looker_role"  {
  description = "Looker users role for website access. Roles can be Admin, User, Op, Viewer, and Public"
}

variable "s3_looker_bucket_name"  {
  description = "S3 bucket for looker configuration"
}

variable "s3_looker_log_bucket_name"  {
  description = "S3 bucket for looker logs"
}

variable "s3_looker_access_log_bucket_name"  {
  description = "S3bucket for alb access logs"
}

variable "ingress_ips"  {
  description = "Instance ingress ips to allow. Used by ALB Security Group and WAF"
}

variable "ingress_ip_description"  {
  description = "Instance ingress ip description."
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
```
