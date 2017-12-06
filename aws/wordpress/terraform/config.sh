#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y httpd redis-server php php-mysql php-redis git nfs-utils
mkdir /var/www/html/efs-mount-point
echo "maxmemory 256mb" | sudo tee -a /etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" | sudo tee -a /etc/redis/redis.conf
wget https://assets.digitalocean.com/articles/wordpress_redis/object-cache.php
sudo mv object-cache.php /var/www/html/efs-mount-point/wordpress/aws/wordpress/wp-content/
$ sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 file-system-id.efs.aws-region.amazonaws.com:/ /var/www/html/efs-mount-point

git clone --recursive -j8 ${git_repo}
cd ./homelab/aws/wordpress
sudo mv ./index.php /var/www/html
sudo mv ./wp-content/ /var/www/html
sudo mv ./wp-config.php /var/www/html
sudo mv ./wordpress/ /var/www/html

sudo chkconfig httpd on
sudo chkconfig redis-server on
sudo service httpd start
sudo service redis-server start