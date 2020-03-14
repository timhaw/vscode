#!/bin/bash

mkdir /home/docker
cat > /home/docker/docker-compose.yml <<EOF
${DOCKER_COMPOSE}
EOF

mkdir /home/jenkins
cat > /home/jenkins/plugins.txt <<EOF
${JENKINS_PLUGINS}
EOF

cat > /home/jenkins/security.groovy <<EOF
${JENKINS_SECURITY}
EOF

cat > /home/jenkins/Dockerfile <<EOF
${JENKINS_DOCKERFILE}
EOF

cat > /home/jenkins/ssh_credentials.xml <<EOF
${JENKINS_SSH}
EOF

cat > /home/jenkins/userpass_credentials.xml <<EOF
${JENKINS_USERPASS}
EOF

cat > /home/jenkins/SSHBuildWrapper.xml <<EOF
${JENKINS_SSHBUILDWRAPPER}
EOF

cat > /home/jenkins/GlobalLibraries.xml <<EOF
${JENKINS_GLOBALLIBRARIES}
EOF

cat > /home/jenkins/JenkinsLocationConfiguration.xml <<EOF
${JENKINS_LOCATIONCONFIGURATION}
EOF

cat > /home/jenkins/ansible.txt <<EOF
${JENKINS_ANSIBLE}
EOF

cat > /home/jenkins/tasks.txt <<EOF
${JENKINS_TASKS}
EOF

cat > /home/jenkins/local.txt <<EOF
${JENKINS_LOCAL}
EOF

cat > /home/jenkins/template.xml <<EOF
${JENKINS_TEMPLATE}
EOF

mkdir /home/ansible
cat > /home/ansible/.gitconfig <<EOF
${ANSIBLE_GITCONFIG}
EOF
