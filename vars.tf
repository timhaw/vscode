variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "/home/vagrant/.ssh/id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "/home/vagrant/.ssh/id_rsa.pub"
}

variable "SSH_KEY_PAIR" {
  default = "Terraform"
}

variable "AMIS" {
  type = map(string)
  default = {
    eu-west-1 = "ami-0987ee37af7792903"
    eu-west-2 = "ami-05945867d79b7d926"
    eu-west-3 = "ami-00c60f4df93ff408e"
  }
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "INSTANCE_DEVICE_NAME" {
  default = "/dev/xvdh"
}

variable "SSD_DEVICE_NAME" {
  default = "/dev/nvme1n1"
}

variable "DOCKER_COMPOSE" {
  type = string
  default = <<EOF
version: '3.1'
services:
  jenkins:
    container_name: jenkins
    restart: unless-stopped
    image: timhaw/jenkins
    user: jenkins
    network_mode: host
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - /data/var/jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
  semaphore:
    image: timhaw/ansible
    user: ansible
    network_mode: host
    command: bash -c "semaphore -setup < semaphore.stdin"
    command: >
      bash -c "cp /home/docker/semaphore.sql /home/ansible/semaphore.sql &&
                semaphore -setup < /home/docker/semaphore.stdin"
    volumes:
      - /home/ansible:/home/ansible
      - /var/run/docker.sock:/var/run/docker.sock
  ansible:
    container_name: ansible
    restart: unless-stopped
    image: timhaw/ansible
    user: ansible
    network_mode: host
    entrypoint: semaphore -config /home/ansible/config.json
    volumes:
      - /home/ansible:/home/ansible
      - /var/run/docker.sock:/var/run/docker.sock
  mysql:
    container_name: mysql
    restart: unless-stopped
    image: mariadb
    user: <username>
    environment:
      - MYSQL_ROOT_PASSWORD=<password>
      - MYSQL_DATABASE=semaphore
    network_mode: host
    ports:
      - 3306:3306
    healthcheck:
        test: ["CMD", "mysqladmin","ping", "-h", "localhost"]
        interval: 30s
        timeout: 10s
        retries: 5
EOF
}

variable "JENKINS_PLUGINS" {
  type = string
  default = <<EOF
ant:latest
build-timeout:latest
credentials-binding:latest
cloudbees-folder:latest
git:latest
github-branch-source:latest
gradle:latest
http_request:latest
ldap:latest
mailer:latest
matrix-auth:latest
antisamy-markup-formatter:latest
pam-auth:latest
workflow-aggregator:latest
pipeline-github-lib:latest
pipeline-stage-view:latest
pipeline-utility-steps:latest
ssh:latest
subversion:latest
timestamper:latest
ws-cleanup:latest
EOF
}

variable "JENKINS_SECURITY" {
  type = string
  default = <<EOF
#!groovy
import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
def instance = Jenkins.getInstance()
def user = "<username>"
def pass = "<password>"
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(user, pass)
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)
EOF
}

variable "JENKINS_DOCKERFILE" {
  type = string
  default = <<EOF
FROM jenkins/jenkins:lts-alpine
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV DOCKER_VERSION=19.03.4
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
USER root
RUN curl -sfL -o docker.tgz \
  "https://download.docker.com/linux/static/stable/x86_64/docker-\$DOCKER_VERSION.tgz" && \
  tar -xzf docker.tgz docker/docker --strip=1 --directory /usr/local/bin && rm docker.tgz
COPY .ssh/known_hosts /root/.ssh/known_hosts
RUN delgroup ping
RUN addgroup -S -g 999 docker
RUN adduser -SD -s /bin/bash -u 999 -G docker -h /home/docker docker
RUN addgroup jenkins docker
RUN chmod -R 774 /home/docker
USER jenkins
EOF
}

variable "JENKINS_SSH" {
  type = string
  default = <<EOF
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.18">
  <scope>GLOBAL</scope>
  <id></id>
  <description>This credential holds the SSH private key for <user> in the Jenkins secure store.</description>
  <username></username>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>
      <secret-redacted/>
    </privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
}

variable "JENKINS_USERPASS" {
  type = string
  default = <<EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials@2.3.0">
  <scope>GLOBAL</scope>
  <id></id>
  <description>This credential holds the username and password in the Jenkins secure store.</description>
  <username></username>
  <password></password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
}

variable "JENKINS_SSHBUILDWRAPPER" {
  type = string
  default = <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<org.jvnet.hudson.plugins.SSHBuildWrapper_-DescriptorImpl plugin="ssh@2.6.1">
  <sites>
    <org.jvnet.hudson.plugins.CredentialsSSHSite>
      <hostname>localhost</hostname>
      <username></username>
      <port>22</port>
      <credentialId></credentialId>
      <serverAliveInterval>0</serverAliveInterval>
      <timeout>0</timeout>
      <pty>false</pty>
    </org.jvnet.hudson.plugins.CredentialsSSHSite>
  </sites>
</org.jvnet.hudson.plugins.SSHBuildWrapper_-DescriptorImpl>
EOF
}

variable "JENKINS_GLOBALLIBRARIES" {
  type = string
  default = <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<org.jenkinsci.plugins.workflow.libs.GlobalLibraries plugin="workflow-cps-global-lib@2.15">
  <libraries>
    <org.jenkinsci.plugins.workflow.libs.LibraryConfiguration>
      <name>semaphore</name>
      <retriever class="org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever">
        <scm class="jenkins.plugins.git.GitSCMSource\" plugin=\"git@3.12.1">
          <id>9c75bc66-8df5-49b9-b547-0ab6d21e7a12</id>
          <remote>https://github.com/timhaw/semaphore.git</remote>
          <credentialsId>ansible-ssh-key</credentialsId>
          <traits>
            <jenkins.plugins.git.traits.BranchDiscoveryTrait/>
          </traits>
        </scm>
      </retriever>
      <defaultVersion>master</defaultVersion>
      <implicit>false</implicit>
      <allowVersionOverride>true</allowVersionOverride>
      <includeInChangesets>true</includeInChangesets>
    </org.jenkinsci.plugins.workflow.libs.LibraryConfiguration>
  </libraries>
</org.jenkinsci.plugins.workflow.libs.GlobalLibraries>
EOF
}

variable "JENKINS_LOCATIONCONFIGURATION" {
  type = string
  default = <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<jenkins.model.JenkinsLocationConfiguration>
  <adminAddress>tim@intercress.com</adminAddress>
  <jenkinsUrl>http://jenkins.terraform.intercress.org:8080/</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>
EOF
}

variable "JENKINS_ANSIBLE" {
  type = string
  default = <<EOF
This job runs an Ansible playbook that starts up the Docker containers for MySQL, Semaphore, and Ansible
then runs 'ansible-pull' from within the Ansible container to clone the Ansible directory structure from
github, then run the initial playbook 'local.yml'. This playbook completes the Ansible deployment by installing
and configuring housekeeping services such as SNMP and the NTP client, and pulling any additional required
Ansible modules from their respective git repositories.
EOF
}

variable "JENKINS_TASKS" {
  type = string
  default = <<EOF
This job runs a Groovy script that adds a new Jenkins job to create an Ansible task in Semaphore. It creates a
Semaphore project, ssh Key record, repository, template, and task entry, as required.
EOF
}

variable "JENKINS_LOCAL" {
  type = string
  default = <<EOF
This job creates an example Jenkins job that re-runs the Ansible playbook 'local.yml', that is run initially
during 'ansible-pull', to complete the Ansible server deployment.
EOF
}

variable "JENKINS_TEMPLATE" {
  type = string
  default = <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.35">
  <actions/>
  <description>
  </description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.74">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@3.12.1">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>git@github.com:timhaw/ansible.git</url>
          <credentialsId>ansible-ssh-key</credentialsId>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/master</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath></scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
}

variable "ANSIBLE_GITCONFIG" {
  type = string
  default = <<EOF
[user]
  name = timhaw
  email = tim@intercress.com
EOF
}