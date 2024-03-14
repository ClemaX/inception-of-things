#!/bin/bash

set -eu

# Add Fasttrack APT Repository
cat >> /etc/apt/sources.list << EOF
deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib
deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-backports-staging main contrib
EOF

# Update and upgrade Packages
apt update
apt upgrade

# Install Fasttrack Repository Keyring
apt install fasttrack-archive-keyring
