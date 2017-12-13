#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y php71 httpd24 php71-opcache php71-mysqlnd php71-pecl-redis

sudo usermod -a -G apache ec2-user
sudo chown -R apache:apache /var/www
sudo chgrp -R apache:apache /var/www
sudo chmod 2755 /var/www
find /var/www -type d -exec sudo chmod 2755 {} \;
find /var/www -type f -exec sudo chmod 0644 {} \;

sudo awk '/AllowOverride/ && ++i==4 {sub(/None/,"All")}1' /etc/httpd/conf/httpd.conf | sudo tee tmp
sudo mv tmp /etc/httpd/conf/httpd.conf

echo '
<IfModule mod_cache.c>
    <IfModule mod_cache_disk.c>
        CacheEnable disk /
        CacheRoot /var/cache/httpd
        CacheDefaultExpire 3600
        CacheDisable /wordpress/wp-admin
        CacheIgnoreNoLastMod On
    </ifModule>
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresDefault A60
        ExpiresByType image/jpg A3600
        ExpiresByType image/jpeg A3600
        ExpiresByType image/gif A3600
        ExpiresByType image/png A3600
        ExpiresByType text/css A3600
        ExpiresByType application/pdf A3600
        ExpiresByType text/x-javascript A3600
        ExpiresByType application/x-shockwave-flash A3600
        ExpiresByType image/x-icon A3600
    </IfModule>
</ifModule>' | sudo tee -a /etc/httpd/conf/httpd.conf

sudo chkconfig httpd on
sudo service httpd start
