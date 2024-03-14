#!/bin/bash

set -eu

# Install Vagrant
apt install --no-install-recommends vagrant

# Add Shared Folder to fstab
echo 'vagrant /vagrant vboxsf defaults 0 0' >> /etc/fstab

# Add IOT hostnames to hosts
echo '192.168.56.110	a.iot b.iot c.iot argocd.iot wil.iot'

# Reboot to apply changes
reboot
