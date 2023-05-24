#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info "Generating initramfs"
mkinitcpio -P > $OUTPUT 2>&1
