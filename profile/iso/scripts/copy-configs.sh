#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info 'Copying <user>iso</user> configs'
cp -L -r "$DB"/profile/iso/root/* / > $OUTPUT

