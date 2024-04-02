#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

# Install Squid
apt-get -yq install --no-install-recommends squid

# Configure Squid to allow connections from localnet
cat > /etc/squid/conf.d/debian.conf << EOF
# Logs are managed by logrotate on Debian
logfile_rotate 0

http_access allow localnet
EOF
