# -*- mode: ruby -*-
# vi: set ft=ruby :

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
end
