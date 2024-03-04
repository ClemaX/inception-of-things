VAGRANTFILE_API_VERSION = "2"

HAS_LINKED_CLONE = Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')

VM_NAME="#{ENV['USER']}"

VM_SUFFIX_SERVER="S"
VM_SUFFIX_AGENT="SW"

K3S_SERVER_IP="192.168.56.110"

nodes = [
	{ type: "server", name: "#{VM_NAME}#{VM_SUFFIX_SERVER}", ip: K3S_SERVER_IP },
	{ type: "agent", name: "#{VM_NAME}#{VM_SUFFIX_AGENT}", ip: "192.168.56.111" },
]

VM_PROVISION_K3S = "provision/k3s.sh"
VM_PROVISION_K3S_SERVER = "provision/k3s-server.sh"
VM_PROVISION_K3S_AGENT = "provision/k3s-agent.sh"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "generic/alpine318"

	nodes.each do |node|
		config.vm.define node[:name], primary: node[:type] == "server" do |node_config|
			# Setup VirtualBox provider
			node_config.vm.provider "virtualbox" do |vbox|
				vbox.name = node[:name]
				# Use linked clones if available
				vbox.linked_clone = true if HAS_LINKED_CLONE
			end

			# Setup host-only networking
			node_config.vm.network "private_network", ip: node[:ip]
			node_config.vm.hostname = node[:name]

			if node[:type] == "server"
				# Download K3S Server token
				node_config.trigger.after [:provision, :up] do |trigger|
					trigger.name = "download token"
					trigger.run = { inline: "/bin/bash -c 'vagrant ssh --no-tty -c \"sudo cat /var/lib/rancher/k3s/server/node-token\" \"#{node[:name]}\" > shared/token'" }
				end

				# Provision K3S Server
				node_config.vm.provision "shell", path: VM_PROVISION_K3S	
			elsif node[:type] == "agent"
				node_config.vm.synced_folder "shared/", "/mnt/shared/"

				# Provision K3S Agent
				node_config.vm.provision "shell", path: VM_PROVISION_K3S, env: { :K3S_URL => "https://#{K3S_SERVER_IP}", :K3S_TOKEN_FILE => "/mnt/shared/token" }
			end

		end
	end
end
