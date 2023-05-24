#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1
set -e

info 'Updating keyring'

info 'Copying pacman configuration'
cp "$DB"/profile/"$VARIANT"/root/etc/pacman.conf /etc/pacman.conf
cp -r "$DB"/profile/"$VARIANT"/root/etc/pacman.d /etc/

if [ "$NET" = 'offline' ]; then
    cp "$DB"/profile/"$VARIANT"/configs/pacman.conf.offline /etc/pacman.conf

    REPOS="Server = file://$DB/packages/offline/$VARIANT/packages\n"

    sed -i -e "s|# insert|# insert\n$REPOS|g" /etc/pacman.conf
    sed -i -e "s|#CacheDir    = /var/cache/pacman/pkg/|CacheDir    = $DB/packages/offline/$VARIANT/packages/|g" /etc/pacman.conf
fi


if [ "$VARIANT" = 'artix' ]; then
    PACKAGES_LIST='artix-archlinux-support '
    if [ "$LIB32" -eq 1 ]; then
        PACKAGES_LIST="$PACKAGES_LIST lib32-artix-archlinux-support"
    fi
    pacman $PACMAN_ARGUMENTS -Syu $PACKAGES_LIST 2> /dev/stdout | grep -v 'skipping' > $OUTPUT 2>&1
fi
pacman-key --init > $OUTPUT 2>&1
pacman-key --populate > $OUTPUT 2>&1

if [ "$TYPE" = 'iso' ]; then
    sed -i 's|CheckSpace|#CheckSpace|g' /etc/pacman.conf
fi

sed -i 's|#PACMAN_AUTH=()|PACMAN_AUTH=(doas)|' /etc/makepkg.conf
sed -i 's|#MAKEFLAGS="-j2"|MAKEFLAGS="-j$(nproc)"|' /etc/makepkg.conf
