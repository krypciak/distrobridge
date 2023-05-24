#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

for group in $PACKAGE_GROUPS; do
    . "$DB"/packages/"$group".sh
    CONFIG_FUNC="${VARIANT}_${group}_configure"
    if command -v "$CONFIG_FUNC" > /dev/null 2>&1; then
        info "Configuring <user>$group</user>"
        eval "$CONFIG_FUNC" > $OUTPUT 2>&1
    fi
done

