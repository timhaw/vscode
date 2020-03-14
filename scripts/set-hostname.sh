#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 2. set hostname
echo "docker.service.com" > /etc/hostname
hostname docker.service.com
sed -i "/^127.0.0.1/a `hostname -I`\tdocker.service.com\tdocker" /etc/hosts
