#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

echo "I am the user provisionning script"

cat >>/home/vagrant/.bashrc << 'EOF'
sudo -i
EOF

