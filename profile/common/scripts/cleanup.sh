#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

set -a

info 'Cleaning up'
mkdir -p /mnt/pen /mnt/hdd /mnt/ssd /mnt/share /mnt/redpen /mnt/blackpen

rm -rf /dotfiles &

rm -rf "$USER_HOME"/.cache
mkdir -p "$USER_HOME"/.cache
echo 0 > "$USER_HOME"/.cache/update
chown -R "$USER1:$USER_GROUP" "$USER_HOME" &

cp "$DB"/profile/common/root/etc/doas.conf /etc/doas.conf
chmod 0040 /etc/doas.conf

cleanup() {
    [ -d "$1" ] && find "$1" -type f -delete > /dev/null 2>&1
}

cleanup /var/log
cleanup /var/tmp
[ "$MODE" != 'live' ] && cleanup /tmp

rm -f /etc/machine-id

. "$DB"/profile/"$VARIANT"/scritps/cleanup.sh

wait $(jobs -p)
