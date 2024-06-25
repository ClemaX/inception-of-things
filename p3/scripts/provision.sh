#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

server_ip="192.168.56.110"

echo I am provisioning server...
apt-get -yq update
apt-get -yq upgrade 2>&1

apt-get install -yq curl docker git fuse htop

# k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
mv ./nvim.appimage /usr/bin/nvim
chmod +x /usr/bin/nvim

# enable docker daemon service
service enable docker
