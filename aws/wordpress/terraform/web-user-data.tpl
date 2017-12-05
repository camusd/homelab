#!/bin/bash
echo "export TF_VAR_db_name=${db_name}" >> /etc/profile
echo "export TF_VAR_db_username=${db_username}" >> /etc/profile
echo "export TF_VAR_db_password=${db_password}" >> /etc/profile
echo "export DB_HOST=${db_host}" >> /etc/profile
sudo yum -y update
sudo yum -y install httpd
sudo service httpd start