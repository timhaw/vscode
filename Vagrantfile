# -*- mode: ruby -*-
# vi: set ft=ruby :

system("
  if [ #{ARGV[0]} = 'up' ]; then
    git secret reveal -f
    eval $(sed 's/[[:space:]]*=[[:space:]]\s*/=/g' credentials | grep -v '\\[default\\]' | sed 's/^/export /')
    echo 'AWS_ACCESS_KEY = \"'$aws_access_key_id'\"' > terraform.tfvars
    echo 'AWS_SECRET_KEY = \"'$aws_secret_access_key'\"' >> terraform.tfvars
    export VAGRANT_HOME=`pwd`
    rm -f credentials
  fi
")
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 8080, host: 8088

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.synced_folder "/Users/timhaw/Dropbox/Source/Repos", "/Repos"
  config.vm.synced_folder "#{ENV['VAGRANT_HOME']}", "/var/vscode_home/", type: "rsync",
  rsync__exclude: [".git*", "credentials*", "Vagrant-vscode.code-workspace", "*.log", "Vagrantfile", "Terraform.pem"]
  
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
 
    # Customize the amount of memory on the VM:
    # vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
#=begin
  config.vm.provision "shell", inline: <<-SHELL
  eval $(sed 's/[[:space:]]*=[[:space:]]\s*/=/g' /var/vscode_home/terraform.tfvars | sed 's/^/export /')
#<<COMMENT  
    #
    # Update Repository
    #
    apt-get update &> /dev/null
    #
    # Install unzip
    # 
    apt-get install unzip &> /dev/null
    #
    # Generate Public/Private Key Pair
    #
    sudo -u vagrant bash -c "ssh-keygen -f /home/vagrant/.ssh/id_rsa -q -N ''" 
    #
    # Install VSCode
    #
    cd /home/vagrant
    wget -q https://github.com/cdr/code-server/releases/download/2.1698/code-server2.1698-vsc1.41.1-linux-x86_64.tar.gz
    tar -xzf code-server2.1698-vsc1.41.1-linux-x86_64.tar.gz
    mv code-server2.1698-vsc1.41.1-linux-x86_64/code-server /usr/local/bin/
    rm -rf code-server2.1698-vsc1.41.1-linux-x86_64
    rm -f code-server2.1698-vsc1.41.1-linux-x86_64.tar.gz
    #
    # Install Terraform
    #
    cd /home/vagrant
    wget -q https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
    unzip terraform_0.12.19_linux_amd64.zip
    mv terraform /usr/local/bin/
    rm -f terraform_0.12.19_linux_amd64.zip
    #
    # Install Kops
    #
    cd /home/vagrant
    rm -f kops-linux-amd64
    wget -q https://github.com/kubernetes/kops/releases/download/1.14.0/kops-linux-amd64
    chown vagrant:vagrant kops-linux-amd64
    mv kops-linux-amd64 /usr/local/bin/kops
    chmod +x /usr/local/bin/kops
    apt-get install -y python3-pip &> /dev/null
    python3 -m pip install --upgrade pip
    # 
    # Install AWS CLI
    #
    python3 -m pip install awscli
    su - vagrant bash -c "aws configure set aws_access_key_id $AWS_ACCESS_KEY"
    su - vagrant bash -c "aws configure set aws_secret_access_key $AWS_SECRET_KEY"
    su - vagrant bash -c "aws configure set default.region eu-west-2"
    #
    # Install Kubectl
    #
    cd /home/vagrant
    wget -q https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl
    chown vagrant:vagrant kubectl
    chmod +x kubectl
    mv kubectl /usr/local/bin/kubectl
    #
    # Install Docker
    #
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common &> /dev/null
    cd /home/vagrant
    wget -q https://download.docker.com/linux/ubuntu/gpg
    apt-key add gpg
    rm -f gpg
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &> /dev/null
    apt-get update &> /dev/null
    apt-get install -y docker-ce docker-ce-cli containerd.io &> /dev/null
    usermod -aG docker vagrant
    #
    # Install Skaffold
    #
    cd /home/vagrant
    wget -q https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
    chown vagrant:vagrant skaffold-linux-amd64
    chmod +x skaffold-linux-amd64
    mv skaffold-linux-amd64 /usr/local/bin/skaffold
    #
    # Install Istio
    #
    cd /home/vagrant
    wget -q https://github.com/istio/istio/releases/download/1.4.3/istio-1.4.3-linux.tar.gz
    tar -xzvf istio-1.4.3-linux.tar.gz
    chown -R vagrant:vagrant istio-1.4.3
    echo 'export PATH="$PATH:/home/vagrant/istio-1.4.3/bin"' >> /home/vagrant/.profile
    rm -rf istio-1.4.3
    rm -f istio-1.4.3-linux.tar.gz
    #
    # Install VSCode Extensions
    #
    cd /var/vscode_home
    EXTENSIONS=`cat extensions.txt`
    for EXTENSION_ID in $EXTENSIONS
    do
      export INSTALL_COMMAND="sudo code-server --install-extension $EXTENSION_ID"
      echo $INSTALL_COMMAND
      eval $INSTALL_COMMAND
    done
    #
    # Start VSCode
    #
    cat > /etc/systemd/system/code-server.service <<EOF
Description=Visual_Studio_Code

Wants=network.target
After=syslog.target network-online.target
    
[Service]
Type=simple
ExecStart=/usr/local/bin/code-server
Restart=on-failure
RestartSec=10
KillMode=process
Environment=PASSWORD=vscode
    
[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable code-server
    sudo systemctl start code-server
    systemctl status code-server
    #
#COMMENT
  SHELL
#=end
end
