#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

echo "I am the user provisionning script"

cat >>/home/vagrant/.bashrc << 'EOF'
sudo -i
EOF

# argocd cli
#curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
#sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
#rm argocd-linux-amd64

# argocd dl
# sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# done in shared folder
# apply argocd resources into our k3d cluster in namespace argocd
# then override argocd-server config with insecure flag to disable tls
# finally apply ingress to redirect our inbound trafik from port 80 to service argocd-server
#cd /vagrant_shared
#sudo kubectl config set-context --current --namespace=argocd
#sudo kubectl apply -f install.yml
#sudo kubectl apply -f config_insecure.yml
#sudo kubectl apply -f traefik_argo_ingress.yml
#
#sudo kubectl wait pod --all --timeout 15m --for=condition=Ready --namespace=argocd
#
## lets go last part, using argocd
#sudo kubectl apply -f argocd-app.yaml
