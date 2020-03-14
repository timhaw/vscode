#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ECDSA="awk '{print \"localhost\",\$1,\$2}' /etc/ssh/ssh_host_ecdsa_key.pub"
JENKINS_PUBLIC="aws ssm get-parameters --name Jenkins_Public_Key --query Parameters[*].Value --output text"
JENKINS_PRIVATE="aws ssm get-parameters --name Jenkins_Private_Key --with-decryption --query Parameters[*].Value --output text"
JENKINS_USERNAME="aws ssm get-parameters --name Jenkins_Username --query Parameters[*].Value --output text"
JENKINS_PASSWORD="aws ssm get-parameters --name Jenkins_Password --with-decryption --query Parameters[*].Value --output text"
DOCKERHUB_USERNAME="aws ssm get-parameters --name Dockerhub_Username --query Parameters[*].Value --output text"
DOCKERHUB_PASSWORD="aws ssm get-parameters --name Dockerhub_Password --with-decryption --query Parameters[*].Value --output text"

# 5. install jenkins
groupadd -g 1000 jenkins
useradd -u 1000 -g 1000 -G 999 -d /home/jenkins -s /bin/bash jenkins
mkdir /home/jenkins/.ssh
eval $JENKINS_PUBLIC > /home/jenkins/.ssh/id_rsa.pub
eval $JENKINS_PRIVATE > /home/jenkins/.ssh/id_rsa
chmod 600 /home/jenkins/.ssh/*
eval $ECDSA > /home/jenkins/.ssh/known_hosts
chmod 740 /home/jenkins/.ssh
chown -R jenkins:jenkins /home/jenkins
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
sudo su - jenkins
cd /home/jenkins
sed -i -e "s/<username>/`eval $JENKINS_USERNAME`/" -e "s/<password>/`eval $JENKINS_PASSWORD`/" /home/jenkins/security.groovy
docker image build -t timhaw/jenkins .
docker login -u `eval $DOCKERHUB_USERNAME` -p `eval $DOCKERHUB_PASSWORD`
docker image push timhaw/jenkins