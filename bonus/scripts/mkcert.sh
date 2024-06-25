#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

# Install mkcert
apt-get -yq install mkcert
