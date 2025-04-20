#!/bin/bash
set -euo pipefail

KVER="$(rpm -q --qf "%{REQUIREVERSION}" kernel-surface)"

mkdir -p "/var/cache/dracut/$KVER"
if [[ -f "/var/cache/dracut/$KVER/initramfs.img" ]]; then
    echo "Cache hit on $KVER!"
else
    dracut --no-hostonly --kver "$KVER" --reproducible -v --add ostree -f "/var/cache/dracut/$KVER/initramfs.img"
fi

cp "/var/cache/dracut/$KVER/initramfs.img" "/lib/modules/$KVER/initramfs.img"
chmod 0600 "/lib/modules/$KVER/initramfs.img"
