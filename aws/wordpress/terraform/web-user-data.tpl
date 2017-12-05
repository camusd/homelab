#!/bin/bash
echo "export TF_VAR_db_name=${db_name}" >> /etc/profile
echo "export TF_VAR_db_username=${db_username}" >> /etc/profile
echo "export TF_VAR_db_password=${db_password}" >> /etc/profile
echo "export DB_HOST=${db_host}" >> /etc/profile
echo "export AUTH_KEY=${wp_auth_key}" >> /etc/profile
echo "export SECURE_AUTH_KEY=${wp_secure_auth_key}" >> /etc/profile
echo "export LOGGED_IN_KEY=${wp_logged_in_key}" >> /etc/profile
echo "export NONCE_KEY=${wp_nonce_key}" >> /etc/profile
echo "export AUTH_SALT=${wp_auth_salt}" >> /etc/profile
echo "export SECURE_AUTH_SALT=${wp_secure_auth_salt}" >> /etc/profile
echo "export LOGGED_IN_SALT=${wp_logged_in_salt}" >> /etc/profile
echo "export NONCE_SALT=${wp_nonce_salt}" >> /etc/profile
sudo yum -y update
sudo yum -y install httpd
sudo yum -y install git
git clone --recursive -j8 ${git_repo}
cd ./homelab/aws/wordpress
sudo mv ./index.php /var/www/html
sudo mv ./wp-content/ /var/www/html
sudo mv ./wp-config.php /var/www/html
sudo mv ./wordpress/ /var/www/html
sudo service httpd start