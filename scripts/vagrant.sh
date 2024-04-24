#!/bin/bash

set -eu

APPS=(a b c argocd dev)

export DEBIAN_FRONTEND=noninteractive

# Install Vagrant
apt-get -yq install --no-install-recommends vagrant

# Add Shared Folder to fstab
echo 'vagrant /vagrant vboxsf defaults 0 0' >> /etc/fstab

# Add IOT hostnames to hosts
echo '192.168.56.110 ${APPS[*]/%/.$domain_name}' >> /etc/hosts

# Install vagrant-reload plugin
su vagrant -c 'vagrant plugin install vagrant-reload'
