#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1
set -e

info "Installing paru (AUR manager)"

if [ -d /tmp/paru ]; then rm -rf /tmp/paru; fi
# If paru is already installed, skip this step
if ! command -v "paru" > /dev/null 2>&1; then
    set +e
    PARU_FILE="$(ls "$DB"/packages/offline/$VARIANT/packages/paru-bin*.pkg.tar.zst 2>/dev/null)"
    set -e
    if [ -f "$PARU_FILE" ]; then
        pacman $PACMAN_ARGUMENTS -U "$PARU_FILE" > $OUTPUT 2>&1
    else
        pacman $PACMAN_ARGUMENTS -Sy git doas > $OUTPUT 2>&1
        git clone https://aur.archlinux.org/paru-bin.git /tmp/paru > $OUTPUT 2>&1
        chown -R "$USER1:$USER_GROUP" /tmp/paru
        chmod -R +wrx /tmp/paru
        cd /tmp/paru || exit 1
        doas -u "$USER1" makepkg -si --noconfirm --needed > $OUTPUT 2>&1
    fi
fi
cp "$DB"/profile/"$VARIANT"/root/etc/paru.conf /etc/paru.conf
 
if [ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook ]; then
    info "Disabling mkinitcpio"
    mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook /90-mkinitcpio-install.hook 
fi

