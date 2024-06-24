#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

# Install Vagrant
apt-get -yq install --no-install-recommends vagrant

# Install vagrant-reload plugin
su vagrant -c 'vagrant plugin install vagrant-reload'


