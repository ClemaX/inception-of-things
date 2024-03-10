#!/bin/sh

set -eu

cluster_name="${1:-iot}"

# Create k3d cluster
k3d cluster create "$cluster_name"

# Wait for Nodes to be Ready
until kubectl wait --for condition=Ready nodes --all 2>/dev/null; do sleep 1; done
