#!/bin/bash

set -euo pipefail

APPS=(gitlab argocd dev)

apps_path="$1"
cluster_name="${2:-iot}"

host_ingress_https_port="${3:-443}"
host_git_ssh_port="${4:-2222}"

domain_name="$cluster_name"

# Trust local CA
mkcert -install 2>&1

# Wait for docker daemon to be ready
until [ -e /var/run/docker.sock ]; do sleep 1; done

# Create k3d cluster
k3d cluster create "$cluster_name" \
	--port "$host_ingress_https_port:443@loadbalancer" \
	--port "$host_git_ssh_port:32022@loadbalancer"

# Wait for Nodes to be Ready
until kubectl wait --timeout 15m --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done

# Add app route hostnames to /etc/hosts
echo "127.0.0.1 ${APPS[*]/%/.$domain_name}" >> /etc/hosts

# Create app namespaces and certificates
mkdir "$HOME/certs"

pushd "$HOME/certs"
	for app in "${APPS[@]}"
	do
		subdomain_name="$app.$domain_name"

		mkcert "$subdomain_name" 2>&1

		kubectl create namespace "$app"
		kubectl create secret tls -n "$app" "$app-$domain_name" \
			--cert "$subdomain_name.pem" \
			--key "$subdomain_name-key.pem"
	done
popd

# Install GitLab
helm repo add gitlab https://charts.gitlab.io
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
	--namespace=gitlab \
	--set "global.hosts.domain=$domain_name" \
	--set "tls.secretName=gitlab-$domain_name" \
	--set "global.shell.port=$host_git_ssh_port" \
	-f "$apps_path/gitlab/installation/values.yaml"

kubectl apply -k "$apps_path/gitlab"

# Install Argo CD
kubectl apply -k "$apps_path/argocd/installation"


# Configure Argo CD Context
until ARGOCD_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d); do sleep 1; done

argocd --grpc-web login --insecure "argocd.$domain_name" --username admin --password "$ARGOCD_PASSWORD"

kubectl config set-context --current --namespace=argocd

# Wait for GitLab deployments to be ready
kubectl wait --timeout 15m --for condition=Available deployment -n gitlab --all &

# Wait for Argo CD pods to be Ready
kubectl wait --timeout 15m --for condition=Ready pods -n argocd --all &

# Restart Squid proxy
service squid restart &

wait

echo "Environment deployed successfully!"
echo
echo "Use the following command to get the initial gitlab root password:"
echo "kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 -d ; echo"
echo
echo "Use the following command to get the initial argocd password:"
echo "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
echo
echo "You can now publish the demo application config to https://gitlab.$domain_name/root/dev.git and configure the repo visibility to 'Public' using the Web UI."
echo
echo "Once this is done, run the following command to deploy the app:"
echo "kubectl apply -f '$apps_path/dev'"
