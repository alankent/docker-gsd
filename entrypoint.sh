#!/bin/bash

# Start up MySQL
/usr/local/bin/mysql-start.sh mysqld

# Start up Samba
if [ "$SAMBA_START" == "1" ]; then
    service samba start
fi

# Start up SSHD (for SFTP access)
/usr/sbin/sshd -D &

# If we have env variables, save them away in Composer auth.json
if [ "$MAGENTO_REPO_USERNAME" != "" -a "$MAGENTO_REPO_PASSWORD" != "" ] ; then
    echo '{"http-basic":{"repo.magento.com":{"username":"'$MAGENTO_REPO_USERNAME'","password":"'$MAGENTO_REPO_PASSWORD'"}}}' > auth.json
fi

# Be friendly, give MySQL a nice head start.
sleep 2

echo $*

exec apache2-foreground
