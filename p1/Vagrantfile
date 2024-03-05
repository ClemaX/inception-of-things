VAGRANTFILE_API_VERSION = "2"

HAS_LINKED_CLONE = Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')

VM_NAME="#{ENV['USER']}"

VM_SUFFIX_SERVER="S"
VM_SUFFIX_AGENT="SW"

VM_SHARE_PATH="shared"
VM_SHARE_MOUNTPOINT="/mnt/shared"

VM_PROVISION_K3S = "provision/k3s.sh"
VM_PROVISION_K3S_TOKEN_GET = "provision/k3s-token-get.sh"

K3S_SERVER_IP="192.168.56.110"

nodes = [
	{
		type: "server",
		ip: K3S_SERVER_IP,
		name: "#{VM_NAME}#{VM_SUFFIX_SERVER}",
	},
	{
		type: "agent",
		ip: "192.168.56.111",
		name: "#{VM_NAME}#{VM_SUFFIX_AGENT}",
	},
]

def provision_server(node, config)
	# Download K3S Server token
	config.trigger.after [:provision, :up] do |trigger|
		trigger.name = "download token"
		trigger.run = {
			path: VM_PROVISION_K3S_TOKEN_GET,
			args: [node[:name], "#{VM_SHARE_PATH}/token"]
		}
	end

	# Install K3S Server
	config.vm.provision "shell",
		path: VM_PROVISION_K3S,
		args: ["--node-external-ip", "#{K3S_SERVER_IP}"]
end

def provision_agent(_, config)
	# Share K3S Server token with Agent
	config.vm.synced_folder "#{VM_SHARE_PATH}/", "#{VM_SHARE_MOUNTPOINT}/"

	# Install K3S Agent
	config.vm.provision "shell",
		path: VM_PROVISION_K3S,
		env: {
			:K3S_URL => "https://#{K3S_SERVER_IP}:6443",
			:K3S_TOKEN_FILE => "#{VM_SHARE_MOUNTPOINT}/token"
		}
end

def provision(node, config)
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

		# Dispatch provisioning according to node type
		send("provision_#{node[:type]}", node, node_config)
	end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "generic/alpine318"

	nodes.each do |node|
		provision node, config
	end
end
