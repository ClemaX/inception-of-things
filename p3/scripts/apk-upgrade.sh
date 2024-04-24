#!/bin/sh

set -eu

# Update package lists
apk update

# Upgrade packages
apk upgrade 2>&1
