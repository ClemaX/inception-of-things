#!/bin/bash

set -euo pipefail

apps_path="$1"
cluster_name="${2:-iot}"

# Wait for docker daemon to be ready
until [ -e /var/run/docker.sock ]; do sleep 1; done

# Create k3d cluster
k3d cluster create "$cluster_name" --port 443:443@loadbalancer

# Wait for Nodes to be Ready
until kubectl wait --timeout 15m --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done

# Install Argo CD
kubectl create namespace argocd
kubectl apply -k "$apps_path/argocd/installation"

# Wait for Argo CD pods to be Ready
kubectl wait --timeout 15m --for condition=Ready pods -n argocd --all

# Add argocd route hostname to /etc/hosts
echo '127.0.0.1	argocd.iot dev.iot' >> /etc/hosts

# Configure Argo CD Context
until ARGOCD_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d); do sleep 1; done

argocd --grpc-web login --insecure argocd.iot --username admin --password "$ARGOCD_PASSWORD"

kubectl config set-context --current --namespace=argocd

# Create dev Namespace
kubectl create namespace dev

# Install Wil's App
kubectl apply -f "$apps_path/dev"

argocd --grpc-web app sync dev
