#cloud-config
package_upgrade: true
packages:
- nfs-utils
runcmd:
- usermod -a -G apache ec2-user
- chown -R apache /var/www
- chgrp -R apache /var/www
- chmod 2755 /var/www
- echo "fs-25fa468c.efs.us-west-2.amazonaws.com:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
- mount -a -t nfs4
