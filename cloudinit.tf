data "template_file" "init-script" {
  template = file("scripts/init.cfg")
  vars = {
    REGION = var.AWS_REGION
  }
}

data "template_file" "config-script" {
  template = file("scripts/config.sh")
}

data "template_file" "shell-script" {
  template = file("scripts/volumes.sh")
  vars = {
    DEVICE = var.SSD_DEVICE_NAME
  }
}

data "template_file" "content-script" {
  template = file("scripts/content.sh")
  vars = {
    DOCKER_COMPOSE = var.DOCKER_COMPOSE
    JENKINS_PLUGINS = var.JENKINS_PLUGINS
    JENKINS_SECURITY = var.JENKINS_SECURITY
    JENKINS_DOCKERFILE = var.JENKINS_DOCKERFILE
    JENKINS_SSH = var.JENKINS_SSH
    JENKINS_USERPASS = var.JENKINS_USERPASS
    JENKINS_SSHBUILDWRAPPER = var.JENKINS_SSHBUILDWRAPPER
    JENKINS_GLOBALLIBRARIES = var.JENKINS_GLOBALLIBRARIES
    JENKINS_LOCATIONCONFIGURATION = var.JENKINS_LOCATIONCONFIGURATION
    JENKINS_ANSIBLE = var.JENKINS_ANSIBLE
    JENKINS_TASKS = var.JENKINS_TASKS
    JENKINS_LOCAL = var.JENKINS_LOCAL
    JENKINS_TEMPLATE = var.JENKINS_TEMPLATE
    ANSIBLE_GITCONFIG = var.ANSIBLE_GITCONFIG
  }
}

# 1. install aws-cli
data "template_file" "install-awscli" {
  template = file("scripts/install-awscli.sh")
  vars = {
    REGION = var.AWS_REGION
  }
}
# 2. set hostname
data "template_file" "set-hostname" {
  template = file("scripts/set-hostname.sh")
}
# 3. install docker
data "template_file" "install-docker" {
  template = file("scripts/install-docker.sh")
}
# 1. install docker-compose
data "template_file" "install-docker-compose" {
  template = file("scripts/install-docker-compose.sh")
}
# 5. install jenkins
data "template_file" "install-jenkins" {
  template = file("scripts/install-jenkins.sh")
}
# 6. deploy jenkins
data "template_file" "deploy-jenkins" {
  template = file("scripts/deploy-jenkins.sh")
}
# 7. configure jenkins
data "template_file" "configure-jenkins" {
  template = file("scripts/configure-jenkins.sh")
}
# 8. install ansible
data "template_file" "install-ansible" {
  template = file("scripts/install-ansible.sh")
}
# 9. cleanup
data "template_file" "cleanup-script" {
  template = file("scripts/cleanup.sh")
}

data "template_cloudinit_config" "cloudinit-jenkins" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.config-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.content-script.rendered
  }

# 1. install aws-cli
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.install-awscli.rendered
  }
# 2. set hostname
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.set-hostname.rendered
  }
# 3. install docker
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.install-docker.rendered
  }
# 4. install docker-compose
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.install-docker-compose.rendered
  }
# 5. install jenkins
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.install-jenkins.rendered
  }
# 6. deploy jenkins
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.deploy-jenkins.rendered
  }
# 7. configure jenkins
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.configure-jenkins.rendered
  }
# 8. install ansible
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.install-ansible.rendered
  }
# 9. cleanup
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.cleanup-script.rendered
  }
}