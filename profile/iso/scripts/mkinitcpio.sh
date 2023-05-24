#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

set +e
mkinitcpio -P -R > /dev/null 2>&1
set -e

info "Generating initramfs"
# shellcheck disable=SC2010
KERNEL_VERSION="$(ls /lib/modules/ | grep "$(pacman -Q "$KERNEL" 2> /dev/null| awk '{print $2}')")"
mkinitcpio -g /boot/initramfs-x86_64.img --kernel "$KERNEL_VERSION" > $OUTPUT 2>&1
if [ -f /boot/vmlinuz-"$KERNEL" ]; then
    mv /boot/vmlinuz-"$KERNEL" /boot/vmlinuz-x86_64
fi

