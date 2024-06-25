#!/bin/bash

set -euo pipefail

APPS=(argocd dev)

apps_path="$1"
cluster_name="${2:-iot}"

host_ingress_https_port="${3:-443}"

domain_name="$cluster_name"

# Wait for docker daemon to be ready
until [ -e /var/run/docker.sock ]; do sleep 1; done

# Create k3d cluster
k3d cluster create "$cluster_name" \
	--port "$host_ingress_https_port:443@loadbalancer"

# Wait for nodes to be Ready
echo "Waiting for nodes to be ready..."
until kubectl wait --timeout 15m --for condition=Ready nodes --all 2>/dev/null
do
	sleep 1
done

# Add app route hostnames to /etc/hosts
echo "127.0.0.1 ${APPS[*]/%/.$domain_name}" >> /etc/hosts

# Create app namespaces
for app in "${APPS[@]}"
do
	kubectl create namespace "$app"
done

# Install Argo CD
kubectl apply -k "$apps_path/argocd/installation"

echo "Waiting for Argo CD pods to be ready..."
until kubectl wait --timeout 15m --for condition=Ready pods -n argocd --all
do
	sleep 1
done

# Install Argo CD App
kubectl apply -f "$apps_path/dev"

# Restart squid proxy
systemctl restart squid

cat <<EOF
Environment deployed successfully!

Use the following command to get the initial Argo CD admin password:
	kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
EOF
