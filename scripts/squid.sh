#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

# Install Squid
apt-get -yq install --no-install-recommends squid

# Configure Squid to allow connections from localnet
cat > /etc/squid/conf.d/debian.conf << EOF
# Logs are managed by logrotate on Debian
logfile_rotate 0
EOF

cat > /etc/squid/conf.d/localnet.conf << EOF
# Allow connections from localnet
http_access allow localnet
EOF

# Configure Squid to disable cache
cat > /etc/squid/conf.d/no-cache.conf << EOF
# Do not cache any response
cache deny all
EOF
