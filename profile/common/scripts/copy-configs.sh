#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info 'Copying common configs'
cp -L -r "$DB"/profile/common/root/* / > $OUTPUT

info "Copying <user>$VARIANT</user> configs"
cp -L -r "$DB"/profile/"$VARIANT"/root/* / > $OUTPUT

