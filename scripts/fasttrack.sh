#!/bin/bash

# add latest version packages to apt

set -eu

export DEBIAN_FRONTEND=noninteractive

# Update Packages
apt-get -yq update

# Install Fasttrack Repository Keyring
apt-get -yq install fasttrack-archive-keyring

# Add Fasttrack APT Repository
cat > /etc/apt/sources.list.d/fasttrack.list << EOF
deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib
deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-backports-staging main contrib
EOF

# Update and upgrade Packages
apt-get -yq update
apt-get -yq upgrade
