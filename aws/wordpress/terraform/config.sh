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
        CacheIgnoreCacheControl On
    </ifModule>
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresDefault "access plus 1 day"
        ExpiresByType image/jpg "access plus 5 days"
        ExpiresByType image/jpeg "access plus 5 days"
        ExpiresByType image/gif "access plus 5 days"
        ExpiresByType image/png "access plus 5 days"
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType application/pdf "access plus 1 month"
        ExpiresByType text/x-javascript "access plus 1 month"
        ExpiresByType application/x-shockwave-flash "access plus 1 month"
        ExpiresByType image/x-icon "access plus 1 year"
    </IfModule>
</ifModule>' | sudo tee -a /etc/httpd/conf/httpd.conf

sudo chkconfig httpd on
sudo service httpd start
