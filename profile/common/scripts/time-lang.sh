#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info "Setting time"
ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
echo "$REGION/$CITY" > /etc/timezone
if command -v ntpd > /dev/null 2>&1 && ping -c 1 gnu.org > /dev/null 2>&1; then
    ntpd > $OUTPUT 2>&1
    hwclock --systohc
else
    hwclock --hctosys
fi

info "Generating locale"
cp "$DB"/profile/common/root/etc/locale.gen /etc/locale.gen
locale-gen > $OUTPUT
echo "LANG=\"$LANG\"" > /etc/locale.conf
export LC_COLLATE="C"

info "Setting the hostname"
echo "$HOSTNAME1" > /etc/hostname
mkdir -p /etc/conf.d
echo "hostname='$HOSTNAME1'" > /etc/conf.d/hostname

