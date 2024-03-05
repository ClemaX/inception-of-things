#!/bin/bash

set -eu

apps_path="$1"

cd "$apps_path"

# Wait for Nodes to be Ready
until kubectl wait --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done

# Create 'iot' Namespace
kubectl create namespace iot

# Deploy Apps
for app_dir in ./*/
do
    app_name=$(basename "$app_dir")

    echo "Deploying '$app_name'..."

    kubectl apply -f "$app_dir"
done

# Deploy Ingress
kubectl apply -f ingress.yml
