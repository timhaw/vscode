#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
JENKINS_USERNAME="aws ssm get-parameters --name Jenkins_Username --query Parameters[*].Value --output text"
JENKINS_PASSWORD="aws ssm get-parameters --name Jenkins_Password --with-decryption --query Parameters[*].Value --output text"
DOCKERHUB_USERNAME="aws ssm get-parameters --name Dockerhub_Username --query Parameters[*].Value --output text"
DOCKERHUB_PASSWORD="aws ssm get-parameters --name Dockerhub_Password --with-decryption --query Parameters[*].Value --output text"
SED="sed"
ANSIBLE_JOB="-e '/<description>/r /home/jenkins/ansible.txt' -e 's/<scriptPath>/&Jenkinsfile/'"
TASKS_JOB="-e '/<description>/r /home/jenkins/tasks.txt' -e 's/<scriptPath>/&Jenkinsfiles\\/tasks.yml/'"
LOCAL_JOB="-e '/<description>/r /home/jenkins/local.txt' -e 's/<scriptPath>/&Jenkinsfiles\\/local.yml/'"
JENKINS_SECRET="-e '/<secret-redacted\\/>/{r /home/jenkins/.ssh/id_rsa' -e 'd}'"
DOCKER_SSH_KEY="-e 's/<id>/&docker-ssh-key/' -e 's/<user>/docker/' -e 's/<username>/&docker/'"
JENKINS_SSH_KEY="-e 's/<id>/&jenkins-ssh-key/' -e 's/<user>/jenkins/' -e 's/<username>/&jenkins/'"
ANSIBLE_SSH_KEY="-e 's/<id>/&ansible-ssh-key/' -e 's/<user>/ansible/' -e 's/<username>/&ansible/'"
DOCKER_SSH_BUILD_WRAPPER="-e 's/<credentialId>/&docker-ssh-key/' -e 's/<username>/&docker/'"
JENKINS_SSH_BUILD_WRAPPER="-e 's/<credentialId>/&jenkins-ssh-key/' -e 's/<username>/&jenkins/'"
ANSIBLE_SSH_BUILD_WRAPPER="-e 's/<credentialId>/&ansible-ssh-key/' -e 's/<username>/&ansible/'"
JENKINS_CLI="java -jar /usr/local/lib/jenkins-cli.jar -s http://localhost:8080"
SEMAPHORE_USERNAME="aws ssm get-parameters --name Semaphore_Username --query Parameters[*].Value --output text"
SEMAPHORE_PASSWORD="aws ssm get-parameters --name Semaphore_Password --with-decryption --query Parameters[*].Value --output text"
SEMAPHORE_USERPASS="-e \"s/<id>/&semaphore/\" -e \"s/<username>/&`eval $SEMAPHORE_USERNAME`/\" -e \"s/<password>/&`eval $SEMAPHORE_PASSWORD`/\""
DOCKERHUB_USERPASS="-e \"s/<id>/&dockerhub/\" -e \"s/<username>/&`eval $DOCKERHUB_USERNAME`/\" -e \"s/<password>/&`eval $DOCKERHUB_PASSWORD`/\""
AUTH="-auth `eval $JENKINS_USERNAME`:`eval $JENKINS_PASSWORD`"
STORE="system::system::jenkins '(global)'"

# 7. configure jenkins
cp /home/jenkins/GlobalLibraries.xml /data/var/jenkins_home/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml
cp /home/jenkins/JenkinsLocationConfiguration.xml /data/var/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml
cp /data/var/jenkins_home/war/WEB-INF/jenkins-cli.jar /usr/local/lib/
eval $SED $DOCKER_SSH_BUILD_WRAPPER /home/jenkins/SSHBuildWrapper.xml > /data/var/jenkins_home/org.jvnet.hudson.plugins.SSHBuildWrapper.xml
eval $SED $JENKINS_SSH_BUILD_WRAPPER /home/jenkins/SSHBuildWrapper.xml >> /data/var/jenkins_home/org.jvnet.hudson.plugins.SSHBuildWrapper.xml
eval $SED $ANSIBLE_SSH_BUILD_WRAPPER /home/jenkins/SSHBuildWrapper.xml >> /data/var/jenkins_home/org.jvnet.hudson.plugins.SSHBuildWrapper.xml
chown -R jenkins:jenkins /data/var/jenkins_home
eval $SED $ANSIBLE_JOB /home/jenkins/template.xml > /home/jenkins/ansible.xml
eval $SED $TASKS_JOB /home/jenkins/template.xml > /home/jenkins/tasks.xml
eval $SED $LOCAL_JOB /home/jenkins/template.xml > /home/jenkins/local.xml
eval $SED $JENKINS_SECRET $DOCKER_SSH_KEY /home/jenkins/ssh_credentials.xml > /home/jenkins/docker_credentials.xml
eval $SED $JENKINS_SECRET $JENKINS_SSH_KEY /home/jenkins/ssh_credentials.xml > /home/jenkins/jenkins_credentials.xml
eval $SED $JENKINS_SECRET $ANSIBLE_SSH_KEY /home/jenkins/ssh_credentials.xml > /home/jenkins/ansible_credentials.xml
eval $SED $SEMAPHORE_USERPASS /home/jenkins/userpass_credentials.xml > /home/jenkins/semaphore_credentials.xml
eval $SED $DOCKERHUB_USERPASS /home/jenkins/userpass_credentials.xml > /home/jenkins/dockerhub_credentials.xml
until $(curl --output /dev/null --silent --head --fail http://localhost:8080)
  do sleep 1
done
sleep 1
eval $JENKINS_CLI $AUTH create-credentials-by-xml $STORE < /home/jenkins/docker_credentials.xml
eval $JENKINS_CLI $AUTH create-credentials-by-xml $STORE < /home/jenkins/jenkins_credentials.xml
eval $JENKINS_CLI $AUTH create-credentials-by-xml $STORE < /home/jenkins/ansible_credentials.xml
eval $JENKINS_CLI $AUTH create-credentials-by-xml $STORE < /home/jenkins/semaphore_credentials.xml
eval $JENKINS_CLI $AUTH create-credentials-by-xml $STORE < /home/jenkins/dockerhub_credentials.xml
eval $JENKINS_CLI $AUTH create-job ansible < /home/jenkins/ansible.xml
eval $JENKINS_CLI $AUTH create-job tasks < /home/jenkins/tasks.xml
eval $JENKINS_CLI $AUTH create-job local < /home/jenkins/local.xml