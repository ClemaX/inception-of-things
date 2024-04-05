#!/bin/sh

set -eu

# Update package lists
apk update

# Upgrade packages
apk upgrade
