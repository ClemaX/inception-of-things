#!/bin/bash

set -eu

# Add Shared Folder to fstab
echo 'vagrant /vagrant vboxsf defaults 0 0' >> /etc/fstab
