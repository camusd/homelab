#!/bin/bash
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_dns_name}:/ /var/www/html/
sudo usermod -a -G apache ec2-user
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2755 /var/www
find /var/www -type d -exec sudo chmod 2755 {} \;
find /var/www -type f -exec sudo chmod 0644 {} \;
