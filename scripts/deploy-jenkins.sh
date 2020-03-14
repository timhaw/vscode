#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
JENKINS_PUBLIC="aws ssm get-parameters --name Jenkins_Public_Key --query Parameters[*].Value --output text"
JENKINS_PRIVATE="aws ssm get-parameters --name Jenkins_Private_Key --with-decryption --query Parameters[*].Value --output text"

# 6. deploy jenkins
mkdir -p /data/var/jenkins_home/.ssh
eval $JENKINS_PUBLIC > /data/var/jenkins_home/.ssh/id_rsa.pub
eval $JENKINS_PRIVATE > /data/var/jenkins_home/.ssh/id_rsa
chmod 600 /data/var/jenkins_home/.ssh/*
cp /home/jenkins/.ssh/known_hosts /data/var/jenkins_home/.ssh/known_hosts
chown -R jenkins:jenkins /data/var/jenkins_home
chmod 740 /data/var/jenkins_home/.ssh
cd /home/jenkins
docker-compose -f /home/docker/docker-compose.yml up -d jenkins
while [ ! -f /data/var/jenkins_home/war/WEB-INF/jenkins-cli.jar ]
do
  sleep 1
done
sleep 1
