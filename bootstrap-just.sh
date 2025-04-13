#!/bin/bash
set -euo pipefail

if command -v just > /dev/null 2>&1; then
    echo "just is already installed."; exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."; exit 1
fi

echo "This script will install just in a temporary overlay that will be lost on"
echo "reboot. Install just in your own overlay to continue using these scripts!"

bootc usr-overlay
dnf5 install just
