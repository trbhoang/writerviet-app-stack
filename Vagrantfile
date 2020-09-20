# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
echo I am provisioning...

cd /vagrant/setup
sudo ./server_init_harden.sh
sudo cp -rvf /vagrant ~/writerviet
cd ~/writerviet

# sudo chmod 0777 forum/data
# chmod 0777 forum/internal_data

# # initialize db data volume
# cd /home/admin/writerviet/db/db_data
# docker run --mount type=volume,source=writerviet_dbdata,target=/data --name helper alpine
# sudo docker cp . helper:/data
# docker rm helper

# # initialize web source volume
# cd /home/admin/writerviet/web/source
# docker run --mount type=volume,source=writerviet_websource,target=/data --name helper alpine
# sudo docker cp . helper:/data
# docker rm helper

# # initialize Caddyfile volume
# cd /home/admin/writerviet/proxy
# docker run --mount type=volume,source=writerviet_caddyfile,target=/data --name helper alpine
# sudo docker cp . helper:/data
# docker rm helper

# # initialize fail2ban config volume
# cd /home/admin/writerviet/fail2ban
# docker run --mount type=volume,source=writerviet_fail2bandata,target=/data --name helper alpine
# sudo docker cp . helper:/data
# docker rm helper

# # initialize vector config volume
# cd /home/admin/writerviet/logger
# docker run --mount type=volume,source=writerviet_vectorconfig,target=/data --name helper alpine
# sudo docker cp vector.toml helper:/data
# docker rm helper

SCRIPT

Vagrant.configure("2") do |config|
  # Base VM OS configuration.
  config.vm.box = "bento/ubuntu-20.04"

  # General VirtualBox VM configuration.
  config.vm.provider :virtualbox do |v|
    v.name = "writerviet-app-stack"
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
	config.vm.network :private_network, ip: "192.168.2.2"
  config.vm.provision "shell", inline: $script
end
