#!/bin/bash

set -eu

k3s_host="$1"
token_dst="$2"

touch "$token_dst"
chmod 600 "$token_dst"

vagrant ssh --no-tty "$k3s_host" -c "
    sudo /bin/bash -c \"
        cd /var/lib/rancher/k3s/server &&
        { until [ -f node-token ]; do sleep 1; done } >&2 &&
        cat node-token
    \"
" > "$token_dst"