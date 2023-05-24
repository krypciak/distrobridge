#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info "Adding user <user>$USER1</user>"
if ! id "$USER1" > /dev/null 2>&1; then
    useradd -s /bin/bash -G tty,ftp,games,network,scanner,users,video,audio,wheel "$USER1" > $OUTPUT
fi
mkdir -p "$USER_HOME"

chown -R "$USER1:$USER_GROUP" "$USER_HOME"
