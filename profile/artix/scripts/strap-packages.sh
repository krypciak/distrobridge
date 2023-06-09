#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1
set -e

info_garr "Preparing to strap packages into <path>$INSTALL_DIR</path>"

# import base package list
. "$DB"/packages/base.sh


mkdir -p "$INSTALL_DIR"/etc
mkdir -p "$INSTALL_DIR"/tmp
mkdir -p "$INSTALL_DIR"/var/lib/pacman
mkdir -p "$INSTALL_DIR"/var/cache/pacman/pkg

cp -r "$DB"/profile/"$VARIANT"/root/etc/pacman.d "$INSTALL_DIR"/etc/

if [ "$NET" = 'offline' ]; then
    cp  "$DB"/profile/"$VARIANT"/configs/pacman.conf.offlinestrap "$INSTALL_DIR"/tmp/pacman.conf
    REPOS="\n[offline]\nSigLevel = PackageRequired\nServer = file://$DB/packages/offline/$VARIANT/packages\n"
    
    sed -i -e "s|LocalFileSigLevel = TrustAll|LocalFileSigLevel = TrustAll\n$REPOS|g" "$INSTALL_DIR"/tmp/pacman.conf
    sed -i -e "s|#CacheDir    = /var/cache/pacman/pkg/|CacheDir    = /packages/|g" "$INSTALL_DIR"/tmp/pacman.conf
else
    cp "$DB"/profile/"$VARIANT"/configs/pacman.conf.strap "$INSTALL_DIR"/tmp/pacman.conf
fi
sed -i -e "s|INSTALL_DIR|$INSTALL_DIR|g" "$INSTALL_DIR"/tmp/pacman.conf

info_barr "Generating keyring"
pacman-key --config "$INSTALL_DIR"/tmp/pacman.conf --init > $OUTPUT 2>&1
pacman-key --config "$INSTALL_DIR"/tmp/pacman.conf --populate archlinux > $OUTPUT 2>&1
info_barr "Straping packages"
pacman --config "$INSTALL_DIR"/tmp/pacman.conf \
    --color=always --needed --noconfirm  \
    -Sy $(${VARIANT}_base_install)  > $OUTPUT 2>&1 

info_barr "Done"

