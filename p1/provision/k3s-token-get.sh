#!/bin/bash

set -eu

TOKEN_SRC='/var/lib/rancher/k3s/server/node-token'

token_dst="$1"

{ until [ -f "$TOKEN_SRC" ]; do sleep 1; done } >&2

umask

cp "$TOKEN_SRC" "$token_dst"