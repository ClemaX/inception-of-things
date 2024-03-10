#!/bin/bash

set -eu

apps_path="$1"
cluster_name="${2:-iot}"

# Create k3d cluster
k3d cluster create "$cluster_name" --port 443:443@loadbalancer

# Wait for Nodes to be Ready
until kubectl wait --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done

# Install Argo CD
kubectl create namespace argocd
kubectl apply -k "$apps_path/argocd/installation"

# Configure Ingress
kubectl apply -f "$apps_path/ingress.yml"

# Configure Argo CD Context
ARGOCD_PASSWORD=$(argocd admin initial-password -n argocd)

argocd login localhost --username admin --password "$ARGOCD_PASSWORD"

kubectl config set-context --current --namespace=argocd

# Install Example App
argocd app create guestbook \
    --repo https://github.com/argoproj/argocd-example-apps.git \
    --path guestbook \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev

argocd app sync guestbook