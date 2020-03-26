#!/bin/bash -xe

secret=`aws secretsmanager get-secret-value --region ${db_region} --secret-id ${looker_secret}`
token=$(echo $secret | jq -r .SecretString)

echo "RDS_KEY=$token" >> /etc/environment
echo "RDS_KEY=$token" >> /etc/profile.d/looker.sh

export RDS_KEY=$token

echo "############# Set initial environment variables for cron and systemd #############"

if [ "`aws s3 ls s3://${s3_looker_bucket_name}/sm_update.sh`" != "" ]; then
    echo "############# sm_update.sh found and copied from s3 #############"
    aws s3 cp s3://${s3_looker_bucket_name}/sm_update.sh /home/looker/looker/sm_update.sh --quiet
fi

if [ "`aws s3 ls s3://${s3_looker_bucket_name}/looker-db.yml`" != "" ]; then
    echo "############# looker-db.yml found and copied from s3 #############"
    aws s3 cp s3://${s3_looker_bucket_name}/looker-db.yml /home/looker/looker/looker-db.yml --quiet  
fi

echo "############# Copy important files from s3 locally #############"

if [ ! -e "/home/looker/looker/looker-db.yml" ]; then
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE DATABASE IF NOT EXISTS ${db_looker_dbname};"
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE USER '${db_looker_username}'@'%' IDENTIFIED BY '${db_looker_password}';"
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "GRANT ALL PRIVILEGES ON ${db_looker_dbname}.* TO '${db_looker_username}'@'%';"
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "FLUSH PRIVILEGES;"
    
    echo "############# Completed database setup #############"

# Create the database credentials file
cat <<EOT | tee -a /home/looker/looker/looker-db.yml
host: ${rds_url}
username: ${db_looker_username}
password: ${db_looker_password}
database: ${db_looker_dbname}
dialect: mysql
port: ${db_port}
ssl: ${db_use_ssl}
EOT

    chown -R looker:looker /home/looker/looker
    chmod 600 /home/looker/looker/looker-db.yml

    aws s3 cp /home/looker/looker/looker-db.yml s3://${s3_looker_bucket_name}/looker-db.yml --quiet

    echo "############# Generated looker-db.yml file #############"
fi

if [ ! -e "/home/looker/looker/sm_update.sh" ]; then
    echo "#!/bin/bash" >> /home/looker/looker/sm_update.sh
    echo $'' >> /home/looker/looker/sm_update.sh
    echo "secret=\`aws secretsmanager get-secret-value --region ${db_region} --secret-id ${looker_secret}\`" >> /home/looker/looker/sm_update.sh
    echo $'' >> /home/looker/looker/sm_update.sh
    echo "token=\$(echo \$secret | jq -r .SecretString)" >> /home/looker/looker/sm_update.sh
    echo $'' >> /home/looker/looker/sm_update.sh

    echo "sudo sed -i -e \"/RDS_KEY/d\" /etc/environment" >> /home/looker/looker/sm_update.sh
    echo "sudo sed -i -e \"/RDS_KEY/d\" /etc/profile.d/looker.sh" >> /home/looker/looker/sm_update.sh

    echo "sudo sed -i -e \"$ a RDS_KEY=\$token\" /etc/environment" >> /home/looker/looker/sm_update.sh
    echo "sudo sed -i -e \"$ a RDS_KEY=\$token\" /etc/profile.d/looker.sh" >> /home/looker/looker/sm_update.sh

    chown -R looker:looker /home/looker/looker
    chmod 700 /home/looker/looker/sm_update.sh

    aws s3 cp /home/looker/looker/sm_update.sh s3://${s3_looker_bucket_name}/sm_update.sh --quiet

    echo "############# Generate sm_update.sh #############"
fi

# Determine the IP address of this instance so that it can be registered in the cluster
export IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo "LOOKERARGS=\"--clustered --no-ssl --prefer-ipv4 -H $IP -p ${node_listener_port} -n ${node_to_node_port} -q "${queue_broker_port}" -d /home/looker/looker/looker-db.yml --shared-storage-dir ${efs_mount_point} --scheduler-threads=${scheduler_threads} --unlimited-scheduler-threads=${unlimited_scheduler_threads} --scheduler-query-limit=${scheduler_query_limit} --per-user-query-limit=${per_user_query_limit} --scheduler-query-timeout=${scheduler_query_timeout} --log-to-file=true\"" | sudo tee -a /home/looker/looker/lookerstart.cfg

chown -R looker:looker /home/looker/looker/
chmod 700 /home/looker/looker/sm_update.sh
chmod 600 /home/looker/looker/looker-db.yml

echo "############# Apply owndership and execution priviliges #############"

mkdir -p ${efs_mount_point}
echo "${efs_dns_name}:/ ${efs_mount_point} efs" | sudo tee -a /etc/fstab
mount -a
chown looker:looker ${efs_mount_point}
cat /proc/mounts | grep looker

echo "############# Mount EFS #############"

ln -s ${efs_mount_point}/deploy_keys /home/looker/.ssh

echo "############# Link deployment keys share to .ssh directory #############"

systemctl enable datadog-agent.service
systemctl enable looker.service
systemctl daemon-reload

echo "############# Enabled looker and datadog systemd #############"

systemctl start datadog-agent.service
systemctl start looker

echo "############# Started up looker service #############"