#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y php71 httpd24 php71-opcache php71-mysqlnd php71-pecl-redis

sudo usermod -a -G apache ec2-user
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2755 /var/www
find /var/www -type d -exec sudo chmod 2755 {} \;
find /var/www -type f -exec sudo chmod 0644 {} \;

sudo awk '/AllowOverride/ && ++i==4 {sub(/None/,"All")}1' /etc/httpd/conf/httpd.conf | sudo tee tmp
sudo mv tmp /etc/httpd/conf/httpd.conf

sudo chkconfig httpd on
sudo service httpd start
