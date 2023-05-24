#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

[ "$ENABLE_SWAP" = '1' ] && sed -i "s|SWAP_UUID|$(blkid "$LVM_DIR"/swap -s UUID -o value)|g" /etc/default/grub
sed -i "s|LVM_GROUP_NAME|$LVM_GROUP_NAME|g" /etc/default/grub
if [ "$ENCRYPT" = '1' ]; then
    sed -i "s/CRYPT_UUID/$(blkid "$CRYPT_PART" -s UUID -o value)/g" /etc/default/grub
    sed -i "s|CRYPT_NAME|$CRYPT_NAME|g" /etc/default/grub
fi

info "Installing grub to <path>$BOOT_DIR_ALONE</path>"
grub-install --target=x86_64-efi --efi-directory="$BOOT_DIR_ALONE" --bootloader-id="$BOOTLOADER_ID" > $OUTPUT 2>&1

info "Generating grub config"
grub-mkconfig -o /boot/grub/grub.cfg > $OUTPUT 2>&1
