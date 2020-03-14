#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DOCKER_PUBLIC="aws ssm get-parameters --name Docker_Public_Key --query Parameters[*].Value --output text"
DOCKER_PRIVATE="aws ssm get-parameters --name Docker_Private_Key --with-decryption --query Parameters[*].Value --output text"

# 3. install docker
groupadd -g 999 docker
useradd -u 999 -g 999 -d /home/docker -s /bin/bash docker
mkdir /home/docker/.ssh
eval $DOCKER_PUBLIC > /home/docker/.ssh/id_rsa.pub
eval $DOCKER_PRIVATE > /home/docker/.ssh/id_rsa
chmod 600 /home/docker/.ssh/*
cp /home/docker/.ssh/id_rsa.pub /home/docker/.ssh/authorized_keys
chown -R docker:docker /home/docker
chmod 740 /home/docker/.ssh
echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
apt-get update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker