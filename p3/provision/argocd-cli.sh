#!/bin/sh

set -eu

version="${1:-v2.10.2}"

cd /tmp

# Download argocd CLI executable
curl -sSL -o argocd-linux-amd64 "https://github.com/argoproj/argo-cd/releases/download/$version/argocd-linux-amd64"

# Install executable
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Remove downloaded file
rm argocd-linux-amd64
