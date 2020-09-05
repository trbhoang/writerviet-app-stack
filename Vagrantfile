# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
echo I am provisioning...

cd /vagrant/setup
sudo ./server_init_harden.sh
sudo cp -rvf /vagrant/app_stack /home/admin/writerviet
cd /home/admin/writerviet

echo Set correct permissions for volumes

# chown -R root:2000 db/db_data
# chmod -R 775 db/db_data
# chmod g+s db/db_data

# chown -R root:2001 app/source
# chmod -R 775 app/source
# chmod g+s app/source

# docker-compose up

# sudo chmod 0777 forum/data
# chmod 0777 forum/internal_data

# initialize db data volume
cd /home/admin/writerviet/db/db_data
docker run --mount type=volume,source=writerviet_dbdata,target=/data --name helper alpine
sudo docker cp . helper:/data
docker rm helper

# initialize web source volume
cd /home/admin/writerviet/web/source
docker run --mount type=volume,source=writerviet_websource,target=/data --name helper alpine
sudo docker cp . helper:/data
docker rm helper

# initialize Caddyfile volume
cd /home/admin/writerviet/proxy
docker run --mount type=volume,source=writerviet_caddyfile,target=/data --name helper alpine
sudo docker cp . helper:/data
docker rm helper

# initialize vector config volume
cd /home/admin/writerviet/logger
docker run --mount type=volume,source=writerviet_vectorconfig,target=/data --name helper alpine
sudo docker cp vector.toml helper:/data
docker rm helper

SCRIPT

Vagrant.configure("2") do |config|
  # Base VM OS configuration.
  config.vm.box = "ubuntu/bionic64"

  # General VirtualBox VM configuration.
  config.vm.provider :virtualbox do |v|
    v.name = "writerviet-tech-stack"
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
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 443, host: 8043
  # config.vm.synced_folder ".", "/vagrant"

  # require plugin https://github.com/leighmcculloch/vagrant-docker-compose
  # config.vagrant.plugins = "vagrant-docker-compose"

  # install docker and docker-compose
  # config.vm.provision :docker
  # config.vm.provision :docker_compose

  config.vm.provision "shell", inline: $script
end
