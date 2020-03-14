#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 9. cleanup
rm -f /home/jenkins/plugins.txt
rm -f /home/jenkins/security.groovy
rm -f /home/jenkins/Dockerfile
rm -f /home/jenkins/template.xml
rm -f /home/jenkins/docker_credentials.xml
rm -f /home/jenkins/jenkins_credentials.xml
rm -f /home/jenkins/ansible_credentials.xml
rm -f /home/jenkins/semaphore_credentials.xml
rm -f /home/jenkins/dockerhub_credentials.xml
rm -f /home/jenkins/ssh_credentials.xml
rm -f /home/jenkins/userpass_credentials.xml
rm -f /home/jenkins/org.jvnet.hudson.plugins.SSHBuildWrapper.xml
rm -f /home/jenkins/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml
rm -f /home/jenkins/template.xml
rm -f /home/jenkins/ansible.txt
rm -f /home/jenkins/ansible.xml
rm -f /home/jenkins/tasks.txt
rm -f /home/jenkins/tasks.xml
rm -f /home/jenkins/local.txt
rm -f /home/jenkins/local.xml
