#!/bin/sh

set -eu

# Add edge channel community and testing apk repos
cat >> /etc/apk/repositories <<EOF
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF

# Update package lists
apk update

# Install kubectl package
apk add kubectl
