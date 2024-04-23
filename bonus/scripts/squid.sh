#!/bin/bash

set -eu

# Install Squid
apk add squid

# Configure Squid
cat > /etc/squid/squid.conf <<'EOF'
http_access allow localhost manager
http_access deny manager

http_access allow all

http_port 3128

cache deny all
EOF
