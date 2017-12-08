#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y php71 httpd24 php71-opcache php71-mysqlnd php71-pecl-redis git varnish

# echo 'fs-25fa468c.efs.us-west-2.amazonaws.com:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0' | sudo tee -a /etc/fstab
# mount -a -t nfs4

sudo usermod -a -G apache ec2-user
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2755 /var/www
find /var/www -type d -exec sudo chmod 2755 {} \;
find /var/www -type f -exec sudo chmod 0644 {} \;

sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sudo sed -i 's/.port = "80"/.port = "8080"/' /etc/varnish/default.vcl
sudo awk '/AllowOverride/ && ++i==4 {sub(/None/,"All")}1' /etc/httpd/conf/httpd.conf | sudo tee tmp
sudo mv tmp /etc/httpd/conf/httpd.conf
sudo sed -i 's/VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/' /etc/sysconfig/varnish

git clone https://github.com/DimitriSteyaert/Varnish-3-wordpress-configuration.git
sudo mv Varnish-3-wordpress-configuration/default.vcl /etc/varnish/default.vcl
sudo rm -rf Varnish-3-wordpress-configuration
sudo chmod 644 /etc/varnish/default.vcl
sudo chmod root:root /etc/varnish/default.vcl

sudo chkconfig httpd on
sudo chkconfig varnish on
sudo service httpd start
sudo service varnish start
