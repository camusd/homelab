#!/bin/bash
export TF_VAR_db_name = ${db_name}
export TF_VAR_db_username = ${db_username}
export TF_VAR_db_password = ${db_password}
export DB_HOST = ${db_host}
sudo yum -y update
sudo yum -y install httpd
sudo service httpd start