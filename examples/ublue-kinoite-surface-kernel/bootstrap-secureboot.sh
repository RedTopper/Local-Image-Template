#!/bin/bash
set -euo pipefail

if mokutil --list-enrolled | grep -q 'linux-surface'; then
    echo "linux-surface key already installed."; exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."; exit 1
fi

echo "This script will load the surface secureboot key into mokutil."
echo "The temporary usr-overlay will be enabled to download and install the key,"
echo "and a copy of the key will be saved into ./key"

bootc usr-overlay || true
dnf5 config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo
dnf5 install surface-secureboot
cp /usr/share/surface-secureboot/surface.cer ./key
