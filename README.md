# What is this?
## THIS IS A WIP

This is the terraform code to create the following Looker architecture.

![AWS](images/looker.jpg)

**tf_s3_state** 

- directory contains the terraform code to create an s3 bucket to store the terraform state for the terraform code in the other directory.

**tf_existing_network**

- directory contains the terraform code to create the complete AWS Looker stack using existing VPC's and Subnets.

**Please refer to https://github.com/turnerlabs/looker_stack_aws_ec2_ami for creating the AMI's that run in this stack.**
