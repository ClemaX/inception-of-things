# -*- mode: ruby -*-
# vi: set ft=ruby :
require File.join(File.dirname(__FILE__), "lib", "Provisioner")

VAGRANTFILE_API_VERSION = "2"

VM_RAM_MB=4096
VM_CPUS=2

VM_IP_SUBNET="192.168.56"
VM_IP_HOSTID_BASE=110

def provision_host(node, config)

end

nodes = [
	{
		type: "host",
		name: "iot",
	},
]

provisioner = Provisioner.new(VM_IP_SUBNET, VM_IP_HOSTID_BASE)

Vagrant.configure("2") do |config|
	config.vm.box = "bento/debian-12.4"

	config.vm.provider "virtualbox" do |vb|
		vb.memory = VM_RAM_MB
		vb.cpus = VM_CPUS
		vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
	end

	provisioner.provision nodes, config
end
