# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
echo I am provisioning...
cd /vagrant/setup
sudo ./server_init_harden.sh
sudo cp -rvf /vagrant/share/docker /docker
sudo chown -R vagrant:vagrant /docker
sudo adduser --system --no-create-home --shell /bin/false --group --disabled-login mysql
sudo chown -R mysql:mysql /docker/db/db-data
SCRIPT

Vagrant.configure("2") do |config|
  # Base VM OS configuration.
  config.vm.box = "bento/ubuntu-18.04"

  # General VirtualBox VM configuration.
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 2
    v.linked_clone = true
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  #
  # ssh vagrant box as admin user:
	#   ssh -p 2222 admin@localhost
	#   ssh admin@192.168.2.2
	#
  # to provision ansible playbook
  #    vagrant provision
  #
	config.vm.network :private_network, ip: "192.168.2.2"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8043

  config.vm.synced_folder ".", "/vagrant"

  # require plugin https://github.com/leighmcculloch/vagrant-docker-compose
  # config.vagrant.plugins = "vagrant-docker-compose"

  # install docker and docker-compose
  # config.vm.provision :docker
  # config.vm.provision :docker_compose

  config.vm.provision "shell", inline: $script

  # config.vm.synced_folder "./share/docker/db/db-data", "/var/lib/mysql",
    # owner: "mysql", group: "mysql"

end
