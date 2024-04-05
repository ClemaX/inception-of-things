#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

# Install debconf-utils
apt-get -yq install debconf-utils

debconf-set-selections <<EOF
virtualbox-ext-pack virtualbox-ext-pack/license select true
EOF

# Install VirtualBox
apt-get -yq install --no-install-recommends virtualbox virtualbox-ext-pack virtualbox-guest-utils virtualbox-dkms linux-headers-amd64
