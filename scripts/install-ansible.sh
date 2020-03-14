#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
JENKINS_USERNAME="aws ssm get-parameters --name Jenkins_Username --query Parameters[*].Value --output text"
JENKINS_PASSWORD="aws ssm get-parameters --name Jenkins_Password --with-decryption --query Parameters[*].Value --output text"
JENKINS_CLI="java -jar /usr/local/lib/jenkins-cli.jar -s http://localhost:8080"
AUTH="-auth `eval $JENKINS_USERNAME`:`eval $JENKINS_PASSWORD`"
STORE="system::system::jenkins '(global)'"
ANSIBLE_PUBLIC="aws ssm get-parameters --name Ansible_Public_Key --query Parameters[*].Value --output text"
ANSIBLE_PRIVATE="aws ssm get-parameters --name Ansible_Private_Key --with-decryption --query Parameters[*].Value --output text"
MYSQL_USERNAME="aws ssm get-parameters --name MySQL_Username --query Parameters[*].Value --output text"
MYSQL_PASSWORD="aws ssm get-parameters --name MySQL_Password --with-decryption --query Parameters[*].Value --output text"

# 8. install ansible
groupadd -g 1001 ansible
useradd -u 1001 -g 1001 -G 999 -d /home/ansible -s /bin/bash ansible
mkdir /home/ansible/.ssh
eval $ANSIBLE_PUBLIC > /home/ansible/.ssh/id_rsa.pub
eval $ANSIBLE_PRIVATE > /home/ansible/.ssh/id_rsa
chmod 600 /home/ansible/.ssh/*
cp /home/ansible/.ssh/id_rsa.pub /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible
chmod 740 /home/ansible/.ssh
echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
sed -i -e "s/<username>/`eval $MYSQL_USERNAME`/" -e "s/<password>/`eval $MYSQL_PASSWORD`/" /home/docker/docker-compose.yml
eval $JENKINS_CLI $AUTH build ansible -s -v