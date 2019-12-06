#!/bin/bash -xe

//////////////////////
# Determine the IP address of this instance so that it can be registered in the cluster
export IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo "LOOKERARGS=\"--no-daemonize -d /home/looker/looker/looker-db.yml --clustered -H $IP --shared-storage-dir /mnt/lookerfiles\"" | sudo tee -a /home/looker/looker/lookerstart.cfg

sudo chown looker:looker looker

# Create the database credentials file
cat <<EOT | sudo tee -a /home/looker/looker/looker-db.yml
host: ${rds_url}
username: ${db_looker_username}
password: ${db_looker_password}
database: ${db_looker_dbname}
dialect: mysql
port: ${db_port}
ssl: ${db_use_ssl}
EOT

# Mount the shared file system
sudo mkdir -p /mnt/lookerfiles
echo "$SHARED_STORAGE_SERVER:/ /mnt/lookerfiles nfs nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport" | sudo tee -a /etc/fstab
sudo mount -a
sudo chown looker:looker /mnt/lookerfiles
cat /proc/mounts | grep looker

# Start Looker (but wait a while before starting additional nodes, because the first node needs to prepare the application database schema)
sudo systemctl daemon-reload
sudo systemctl enable looker.service
if [ $NODE_COUNT -eq 0 ]; then sudo systemctl start looker; else sleep 300 && sudo systemctl start looker; fi
/////////////////////


echo "S3_looker_BUCKET=${s3_looker_bucket_name}" >> /etc/environment
echo "S3_looker_BUCKET=${s3_looker_bucket_name}" >> /etc/profile.d/looker.sh

export S3_looker_BUCKET=${s3_looker_bucket_name}

secret=`/home/ubuntu/venv/bin/aws secretsmanager get-secret-value --region ${db_region} --secret-id ${looker_secret}`
token=$(echo $secret | jq -r .SecretString)

echo "RDS_KEY=$token" >> /etc/environment
echo "RDS_KEY=$token" >> /etc/profile.d/looker.sh

export RDS_KEY=$token

echo "############# Set initial environment variables for cron and systemd #############"

/home/ubuntu/venv/bin/aws s3 cp s3://${s3_looker_bucket_name}/ /home/ubuntu/looker/ --recursive --quiet

echo "############# Copy important files from s3 locally #############"

if [ ! -e "/home/ubuntu/looker/looker.cfg" ]; then
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE DATABASE IF NOT EXISTS ${db_looker_dbname} /*\!40100 DEFAULT CHARACTER SET ${db_charset} */;"
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "CREATE USER '${db_looker_username}'@'%' IDENTIFIED BY '${db_looker_password}';"
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "GRANT ALL PRIVILEGES ON ${db_looker_dbname}.* TO '${db_looker_username}'@'%';"
    mysql --host=${rds_url} --user=${db_master_username} --password=${db_master_password} -e "FLUSH PRIVILEGES;"
    
    echo "############# Completed database setup #############"
fi

if [ ! -e "/home/ubuntu/looker/connect.sh" ]; then
    echo "#!/bin/bash" >> /home/ubuntu/looker/connect.sh
    echo $'' >> /home/ubuntu/looker/connect.sh
    echo "db_port=\"${db_port}\"" >> /home/ubuntu/looker/connect.sh
    echo "db_region=\"${db_region}\"" >> /home/ubuntu/looker/connect.sh
    echo "db_looker_dbname=\"${db_looker_dbname}\"" >> /home/ubuntu/looker/connect.sh
    echo "db_looker_username=\"${db_looker_username}\"" >> /home/ubuntu/looker/connect.sh
    echo "rds_url=\"${rds_url}\"" >> /home/ubuntu/looker/connect.sh
    echo $'' >> /home/ubuntu/looker/connect.sh
    echo "token=\$(echo \$RDS_KEY)" >> /home/ubuntu/looker/connect.sh
    echo "url=\"mysql://\$db_looker_username:\$token@\$rds_url/\$db_looker_dbname"\" >> /home/ubuntu/looker/connect.sh
    echo $'' >> /home/ubuntu/looker/connect.sh
    echo "echo \"\$url"\" >> /home/ubuntu/looker/connect.sh

    chown -R ubuntu:ubuntu /home/ubuntu/looker
    chmod 700 /home/ubuntu/looker/connect.sh

    /home/ubuntu/venv/bin/aws s3 cp /home/ubuntu/looker/connect.sh s3://${s3_looker_bucket_name}/connect.sh --quiet

    echo "############# Generate connect.sh #############"
fi

if [ ! -e "/home/ubuntu/looker/sm_update.sh" ]; then
    echo "#!/bin/bash" >> /home/ubuntu/looker/sm_update.sh
    echo $'' >> /home/ubuntu/looker/sm_update.sh
    echo "secret=\`/home/ubuntu/venv/bin/aws secretsmanager get-secret-value --region ${db_region} --secret-id ${looker_secret}\`" >> /home/ubuntu/looker/sm_update.sh
    echo $'' >> /home/ubuntu/looker/sm_update.sh
    echo "token=\$(echo \$secret | jq -r .SecretString)" >> /home/ubuntu/looker/sm_update.sh
    echo $'' >> /home/ubuntu/looker/sm_update.sh

    echo "sudo sed -i -e \"/RDS_KEY/d\" /etc/environment" >> /home/ubuntu/looker/sm_update.sh
    echo "sudo sed -i -e \"/RDS_KEY/d\" /etc/profile.d/looker.sh" >> /home/ubuntu/looker/sm_update.sh

    echo "sudo sed -i -e \"$ a RDS_KEY=\$token\" /etc/environment" >> /home/ubuntu/looker/sm_update.sh
    echo "sudo sed -i -e \"$ a RDS_KEY=\$token\" /etc/profile.d/looker.sh" >> /home/ubuntu/looker/sm_update.sh

    chown -R ubuntu:ubuntu /home/ubuntu/looker
    chmod 700 /home/ubuntu/looker/sm_update.sh

    /home/ubuntu/venv/bin/aws s3 cp /home/ubuntu/looker/sm_update.sh s3://${s3_looker_bucket_name}/sm_update.sh --quiet

    echo "############# Generate sm_update.sh #############"
fi

if [ ! -e "/home/ubuntu/looker/looker.cfg" ]; then
    
    /home/ubuntu/venv/bin/looker initdb

    chown -R ubuntu:ubuntu /home/ubuntu/looker
    chmod 600 /home/ubuntu/looker/looker.cfg
    chmod 600 /home/ubuntu/looker/unittests.cfg

    echo "############# Initial looker database initialization #############"

    sed -i -e "s/dag_dir_list_interval = 300/dag_dir_list_interval = 120/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/expose_config = False/expose_config = True/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/executor = SequentialExecutor/executor = CeleryExecutor/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/remote_logging = False/remote_logging = True/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/remote_base_log_folder =/remote_base_log_folder = s3:\/\/${s3_looker_log_bucket_name}/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/remote_log_conn_id =/remote_log_conn_id = s3:\/\/${s3_looker_log_bucket_name}/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/load_examples = True/load_examples = False/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/authenticate = False/authenticate = True/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/filter_by_owner = False/filter_by_owner = True/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/secure_mode = False/secure_mode = True/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/donot_pickle = True/donot_pickle = False/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/enable_xcom_pickling = True/enable_xcom_pickling = False/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/base_url = http:\/\/localhost:8080/base_url = http:\/\/${subdomain}/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/endpoint_url = http:\/\/localhost:8080/endpoint_url = http:\/\/${subdomain}/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "/sql_alchemy_conn = sqlite:\/\/\/\/home\/ubuntu\/looker\/looker.db/d" /home/ubuntu/looker/looker.cfg
    sed -i -e "/\[core\]/a\\
sql_alchemy_conn_cmd = /home/ubuntu/looker/connect.sh" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/result_backend = db+mysql:\/\/looker:looker@localhost:3306\/looker/result_backend = redis:\/\/${ec_url}\/0/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/broker_url = sqla+mysql:\/\/looker:looker@localhost:3306\/looker/broker_url = redis:\/\/${ec_url}\/1/g" /home/ubuntu/looker/looker.cfg
    sed -i -e "/auth_backend = looker.api.auth.backend.default/d" /home/ubuntu/looker/looker.cfg
    sed -i -e "/\[webserver\]/a\\
auth_backend = looker.contrib.auth.backends.password_auth" /home/ubuntu/looker/looker.cfg
    sed -i -e "s/rbac = False/rbac = True/g" /home/ubuntu/looker/looker.cfg

    /home/ubuntu/venv/bin/looker -h

    chown -R ubuntu:ubuntu /home/ubuntu/looker
    chmod 600 /home/ubuntu/looker/webserver_config.py

    echo "############# Generate webserver_config.py before initdb  #############"

    /home/ubuntu/venv/bin/looker initdb

    echo "############# Completed looker database initilaization #############"

    /home/ubuntu/venv/bin/looker create_user -u ${looker_username} -e ${looker_emailaddress} -p ${looker_password} -f ${looker_first} -l ${looker_last} -r ${looker_role}

    echo "############# Added looker user #############"

    /home/ubuntu/venv/bin/aws s3 cp /home/ubuntu/looker/looker.cfg s3://${s3_looker_bucket_name}/looker.cfg --quiet
    /home/ubuntu/venv/bin/aws s3 cp /home/ubuntu/looker/unittests.cfg s3://${s3_looker_bucket_name}/unittests.cfg --quiet
    /home/ubuntu/venv/bin/aws s3 cp /home/ubuntu/looker/webserver_config.py s3://${s3_looker_bucket_name}/webserver_config.py --quiet

    echo "############# Copy config files to s3 #############"
fi

chown -R ubuntu:ubuntu /home/ubuntu/looker

chmod 700 /home/ubuntu/looker/connect.sh
chmod 700 /home/ubuntu/looker/sm_update.sh
chmod 600 /home/ubuntu/looker/looker.cfg
chmod 600 /home/ubuntu/looker/unittests.cfg
chmod 600 /home/ubuntu/looker/webserver_config.py

echo "############# Apply owndership and execution priviliges #############"

systemctl enable looker-webserver
systemctl enable looker-scheduler

systemctl daemon-reload

echo "############# Enabled looker systemd #############"

systemctl start looker-webserver
systemctl start looker-scheduler

echo "############# Started up looker service #############"