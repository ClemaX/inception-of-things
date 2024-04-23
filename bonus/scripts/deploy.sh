#!/bin/bash

set -euo pipefail

apps_path="$1"
cluster_name="${2:-iot}"

# Wait for docker daemon to be ready
until [ -e /var/run/docker.sock ]; do sleep 1; done

# Create k3d cluster
k3d cluster create "$cluster_name" --port 443:443@loadbalancer --port 2222:32022@loadbalancer

# Wait for Nodes to be Ready
until kubectl wait --timeout 15m --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done

# Create gitlab namespace
kubectl create namespace gitlab

# Install GitLab
helm repo add gitlab https://charts.gitlab.io
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
	--namespace=gitlab \
	--set "global.ingress.class=none" \
	--set "global.hosts.https=false" \
	--set "global.hosts.domain=iot" \
	--set "global.shell.port=2222" \
	-f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml

# Wait for GitLab deployments to be ready
kubectl wait --timeout 15m --for condition=Available deployment -n gitlab --all

# Install Argo CD
kubectl create namespace argocd
kubectl apply -k "$apps_path/argocd/installation"

# Wait for Argo CD pods to be Ready
kubectl wait --timeout 15m --for condition=Ready pods -n argocd --all

# Add argocd route hostname to /etc/hosts
echo '127.0.0.1	argocd.iot gitlab.iot' >> /etc/hosts

# Configure Argo CD Context
until ARGOCD_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d); do sleep 1; done

argocd --grpc-web login --insecure argocd.iot --username admin --password "$ARGOCD_PASSWORD"

kubectl config set-context --current --namespace=argocd

# Create dev Namespace
kubectl create namespace dev

echo "Environment deployed successfully!"
echo
echo "Use the following command to get the initial gitlab root password:"
echo "kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 -d ; echo"
echo
echo "Use the following command to get the initial argocd password:"
echo "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
echo
echo "You can now publish the demo application config to https://gitlab.iot/root/wil-iot.git and configure the repo visibility to 'Public' using the Web UI."
echo
echo "Once this is done, run the following command to deploy the app:"
echo "kubectl apply -f '$apps_path/wil-iot' && argocd --grpc-web app sync wil-iot"

echo "Tip:"
echo "Use 'git -c http.sslVerify=false' to disable SSL certificate verification."
