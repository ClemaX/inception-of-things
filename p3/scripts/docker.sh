#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -yq update
apt-get -yq upgrade 2>&1

apt-get install -yq curl ca-certificates

# install docker repo to apt keyring
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# add docker repository to apt sources
cat >/etc/apt/sources.list.d/docker.list << EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF

# install docker
apt-get -yq update
apt-get -yq install docker-ce docker-ce-cli containerd.io

# enable docker daemon service
systemctl enable docker
