#!/bin/bash

set -eu

apps_path="$1"

cd "$apps_path"

# Wait for Nodes to be Ready
until kubectl wait --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done

# Create 'iot' Namespace
kubectl create namespace iot

pushd http-server/overlays >/dev/null
    # Deploy Apps
    for overlay_dir in ./*/
    do
        overlay_name=$(basename "$overlay_dir")

        echo "Deploying '$overlay_name'..."

        kubectl apply -k "$overlay_dir"
    done
popd >/dev/null

# Deploy Ingress
kubectl apply -f ingress.yml
