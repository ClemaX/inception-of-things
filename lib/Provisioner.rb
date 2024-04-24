HAS_LINKED_CLONE = Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')

class Provisioner
	def initialize(ip_subnet = nil, ip_hostid_base = nil)
		@ip_subnet = ip_subnet
		@ip_hostid = ip_hostid_base
	end

	def provision(nodes, config)
		nodes.each do |node|
			config.vm.define node[:name], primary: node[:type] == "server" do |node_config|
				# Setup VirtualBox provider
				node_config.vm.provider "virtualbox" do |vbox|
					vbox.name = node[:name]
					# Use linked clones if available
					vbox.linked_clone = true if HAS_LINKED_CLONE
				end

					if @ip_subnet != nil and @ip_hostid != nil
						# Set Node IP 
						node[:ip] = "#{@ip_subnet}.#{@ip_hostid}"
						@ip_hostid += 1

						# Setup host-only networking
						node_config.vm.network "private_network", ip: node[:ip]
						node_config.vm.hostname = node[:name]
					end

				# Dispatch provisioning according to node type
				send("provision_#{node[:type]}", node, node_config)
			end
		end
	end
end
