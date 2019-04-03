# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80  , host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 5432, host: 5433, host_ip: "127.0.0.1"

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
  # config.vm.synced_folder "~/.ssh", "~/.ssh"
  config.ssh.forward_agent = true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #

  config.vm.boot_timeout = 600
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    #vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    export RUBY_VERSION=2.3.1
  #
    apt-get update
    apt-get install -y subversion git telnet

    apt-get install -y libmysqlclient-dev freetds-dev imagemagick libmagickcore-dev libmagickwand-dev libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev curl
  #
    echo 'Install RVM'
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
    \\curl -sSL https://get.rvm.io | bash -s stable

    usermod -a -G rvm vagrant
    source /etc/profile.d/rvm.sh
  #
    echo "Install RUBY $RUBY_VERSION..."
    rvm requirements
    rvm install $RUBY_VERSION
    rvm use $RUBY_VERSION --default
    rvm alias create default $RUBY_VERSION
  #
    sudo apt-get install -y postgresql postgresql-contrib

    sudo su postgres -c "psql -c 'CREATE ROLE vagrant SUPERUSER LOGIN;'"
    gem install bundle
    cd /vagrant
  #
    bundle
  #
    sudo su -l vagrant -c "cd /vagrant && rake db:create"
    sudo su -l vagrant -c "cd /vagrant && rake db:migrate"
    sudo su -l vagrant -c "cd /vagrant && rake redmine:plugins:migrate"
  SHELL
end
