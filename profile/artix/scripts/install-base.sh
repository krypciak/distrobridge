#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

. "$DB"/packages/base.sh

PACKAGE_LIST="$(${VARIANT}_base_install)"

info "Installing <user>base</user>"

if [ "$NET" = 'offline' ]; then
    if ! cd "$USER_HOME"/home/.config/repohub/distrobridge/packages/offline/"$VARIANT"/packages; then
        err "Offline packages dir for variant <user>$VARIANT</user> missing."
        exit 1
    fi
    # shellcheck disable=SC2010
    pacman --noconfirm --needed -U $(ls -1 -- *.pkg.tar.zst | grep -E -e $(echo $PACKAGE_LIST | tr ' ' '\n' | awk '{print "-e ^" $1 "-[[:digit:]]"}' | xargs)) 2> /dev/stdout | grep -v 'skipping' > $OUTPUT 2>&1
else
    if ! pacman $PACMAN_ARGUMENTS -Syu $PACKAGE_LIST > $OUTPUT 2>&1; then
        err "Package installation failed."
        exit 1
    fi
fi

