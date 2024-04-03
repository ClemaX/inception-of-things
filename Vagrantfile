# -*- mode: ruby -*-
# vi: set ft=ruby :
require File.join(File.dirname(__FILE__), "lib", "Provisioner")

VAGRANTFILE_API_VERSION = "2"

VM_RAM_MB=4096
VM_CPUS=4

VM_IP_SUBNET="192.168.57"
VM_IP_HOSTID_BASE=2

VM_PROVISION_FASTTRACK = "provision/fasttrack.sh"
VM_PROVISION_VIRTUALBOX = "provision/virtualbox.sh"
VM_PROVISION_VAGRANT = "provision/vagrant.sh"
VM_PROVISION_SQUID = "provision/squid.sh"


HOST_DEPS = [
	VM_PROVISION_FASTTRACK,
	VM_PROVISION_VIRTUALBOX,
	VM_PROVISION_VAGRANT,
	VM_PROVISION_SQUID,
]

def provision_host(node, config)
	HOST_DEPS.each do |script|
		config.vm.provision "shell",
			path: script
	end

	config.vm.provision "shell",
		reboot: true,
		inline: "echo Rebooting..."
end

nodes = [
	{
		type: "host",
		name: "iot",
	},
]

provisioner = Provisioner.new()

Vagrant.configure("2") do |config|
	config.vm.box = "bento/debian-12.4"

	config.vm.provider "virtualbox" do |vb|
		vb.memory = VM_RAM_MB
		vb.cpus = VM_CPUS
		vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
	end

	provisioner.provision nodes, config
end