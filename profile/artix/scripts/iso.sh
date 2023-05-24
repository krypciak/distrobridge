#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

if [ "$NET" = 'offline' ]; then
    info "Reinstalling kernel"
    PACKAGES="$KERNEL"
    PP="$DB"/packages/offline/"$VARIANT"/packages
    for pack in $PACKAGES; do
        pacman --noconfirm -U "$PP"/$pack-*.pkg.tar.zst > $OUTPUT 2>&1
    done
fi

if [ ! -f /boot/amd-ucode.img ] || [ ! -f /boot/intel-ucode.img ]; then
    info "Reinstalling ucode's"
    pacman --noconfirm -S amd-ucode intel-ucode > $OUTPUT 2>&1
fi
