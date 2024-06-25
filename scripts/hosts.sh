#!/bin/bash

set -eu

domain_name="${1:-iot}"

APPS=(a b c)

# Add IOT hostnames to hosts
echo "192.168.56.110 ${APPS[*]/%/.$domain_name}" >> /etc/hosts
