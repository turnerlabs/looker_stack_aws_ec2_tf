# What is this?

This is the [terraform](https://www.terraform.io/) code to create the following Looker architecture(assuming all the VPC's / Subnets are already in place).

![AWS](images/looker.jpg)

The [tf_s3_state](https://github.com/turnerlabs/looker_stack_aws_ec2_tf/tree/master/tf_s3_state) path contains the terraform code to create an s3 bucket to store the terraform state for the terraform code in the other directory.

The [tf_existing_network](https://github.com/turnerlabs/looker_stack_aws_ec2_tf/tree/master/tf_existing_network) path contains the terraform code to create the complete AWS Looker stack using existing VPC's and Subnets.

# How do I migrate new Looker AMI's to the stack I created in tf_existing_network?

There are several steps required to migrate a new version of Looker.

## Assumptions

* You have followed the instructions [here](https://github.com/turnerlabs/looker_stack_aws_ec2_ami/blob/master/looker_node) to succesfully create a new Looker Node AMI.
* You have followed the instructions [here](https://github.com/turnerlabs/looker_stack_aws_ec2_tf/tree/master/tf_existing_network) to succesfully create a new Looker AWS Stack.


## Steps

1. Modify [asgLooker.tf](https://github.com/turnerlabs/looker_stack_aws_ec2_tf/blob/master/tf_existing_network/asgLooker.tf) setting the max-size, min-size, and desired -capacity to zero.
`max_size                  = "0"
  min_size                  = "0"
  desired_capacity          = "0"`

2. Run `terraform apply ...` to apply the changes and take down all your instances.

3. Delete the `resource "aws_autoscaling_group" "asg_looker" {...}` section in your asgLooker.tf file.

4. Delete the `resource "aws_cloudwatch_metric_alarm" "looker_asg_looker_cpu_utilization_too_high" {..}` section from your snsCloudwatch.tf file.

5. Delete lines 28 - 48 from your cloudwatchDashboard.tf file.

6. Run `terraform apply ...` to apply the changes and remove your auto scale group.

7. Run `git checkout asgLooker.tf snsCloudwatch.tf cloudwatchDashboard.tf` to undo your changes.

8. Run `terraform apply` again with the `-var 'looker_node_ami=<new looker ami>'` set to your new AMI to update the launch config(and the auto sclae group as well) with the new AMI.