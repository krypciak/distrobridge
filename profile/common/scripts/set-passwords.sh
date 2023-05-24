#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info 'Set password for <user>root</user>'
if [ "$ROOT_PASSWORD" != '' ]; then
    info 'Automaticly filling password...'
    ( echo "$ROOT_PASSWORD"; echo "$ROOT_PASSWORD"; ) | passwd root > $OUTPUT 2>&1
else
    n=0
    until [ "$n" -ge 5 ]; do
        passwd root && break
        n=$((n+1)) 
        sleep 3
        err "Please try again. Attempt $n/5"
    done
fi
chsh -s /bin/bash root > /dev/null 2>&1

info "Set password for user <user>$USER1</user>"
if [ "$USER_PASSWORD" != '' ]; then
    info "Automaticly filling password..."
    ( echo "$USER_PASSWORD"; echo "$USER_PASSWORD"; ) | passwd "$USER1" > $OUTPUT 2>&1
else
    n=0
    until [ "$n" -ge 5 ]; do
        passwd $USER1 && break
        n=$((n+1)) 
        sleep 3
        err "Please try again. Attempt $n/5"
    done
fi
chsh -s /bin/bash "$USER1" > /dev/null 2>&1

