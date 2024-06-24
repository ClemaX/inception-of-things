# -*- mode: ruby -*-
# vi: set ft=ruby :
require File.join(File.dirname(__FILE__), "lib", "Provisioner")

VAGRANTFILE_API_VERSION = "2"

VM_RAM_MB=8096
VM_CPUS=6

VM_PROVISION_FASTTRACK = "scripts/fasttrack.sh"
VM_PROVISION_VIRTUALBOX = "scripts/virtualbox.sh"
VM_PROVISION_VAGRANT = "scripts/vagrant.sh"
VM_PROVISION_SQUID = "scripts/squid.sh"
VM_PROVISION_SHARED_FOLDER = "scripts/shared-folder.sh"
VM_PROVISION_HOSTS = "scripts/hosts.sh"

HOST_DEPS = [
	VM_PROVISION_FASTTRACK,
	VM_PROVISION_VIRTUALBOX,
	VM_PROVISION_VAGRANT,
	VM_PROVISION_SQUID,
	VM_PROVISION_SHARED_FOLDER,
	VM_PROVISION_HOSTS,
]

def provision_host(node, config)
	# port squid proxy
	config.vm.network "forwarded_port", guest: 3128, host: 3128

	config.vm.provision "shell",
		inline: "hostnamectl set-hostname #{node[:name]} && sed -i 's/debian-12$/iot/g' /etc/hosts"

	HOST_DEPS.each do |script|
		config.vm.provision "shell",
			path: script
	end

	config.vm.provision "shell",
		inline: "echo \"export 'USER=#{ENV['USER']}'\" >> /home/vagrant/.profile"
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

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "bento/debian-12.5"

	config.vm.provider "virtualbox" do |vb|
		vb.memory = VM_RAM_MB
		vb.cpus = VM_CPUS
		vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
	end


	provisioner.provision nodes, config
end
