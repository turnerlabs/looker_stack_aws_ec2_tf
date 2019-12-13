#!/bin/bash -xe

mkdir -p /home/ec2-user/looker
echo "${efs_dns_name}:/ /home/ec2-user/looker efs" | sudo tee -a /etc/fstab
mount -a
chown ec2-user:ec2-user /home/ec2-user/looker
cat /proc/mounts | grep ec2-user
sleep 1m
echo "############# Mount EFS #############"

aws s3 cp /home/ec2-user/looker/models/ s3://${s3_looker_backup_bucket_name}/models/ --recursive --quiet
echo "############# Copy files from /models to S3 #############"