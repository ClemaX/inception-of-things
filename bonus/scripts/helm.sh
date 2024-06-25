#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor > /usr/share/keyrings/helm.gpg

apt-get install -yq apt-transport-https

cat > /etc/apt/sources.list.d/helm-stable-debian.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
  https://baltocdn.com/helm/stable/debian/ all main
EOF

apt-get update -yq

# Install Helm
apt-get install -yq helm
