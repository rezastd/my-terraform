#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install mysql
apt-get update
apt-get -y install mysql-server
# ufw enable -y
# ufw allow mysql -y
# make sure mysql is started
systemctl restart mysql