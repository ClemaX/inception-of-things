#!/bin/sh

set -eu

# Install docker package
apk add docker

# Start docker daemon at boot
rc-update add docker default
