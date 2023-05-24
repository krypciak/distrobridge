#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1
set -a
set -e

if [ "$MODE" = 'iso' ]; then
    . "$DB"/vars.conf.iso.sh
else
    . "$DB"/vars.conf.sh
fi


. "$DB"/profile/common/scripts/time-lang.sh
. "$DB"/profile/common/scripts/add-user.sh
. "$DB"/profile/common/scripts/temp-doas.sh
. "$DB"/profile/"$VARIANT"/scripts/install-packages.sh
. "$DB"/profile/common/scripts/copy-configs.sh
. "$DB"/profile/iso/scripts/copy-configs.sh
. "$DB"/profile/common/scripts/temp-doas.sh
. "$DB"/profile/common/scripts/install-dotfiles.sh
. "$DB"/profile/common/scripts/set-passwords.sh
. "$DB"/profile/common/scripts/configure-packages.sh

. "$DB"/profile/common/scripts/cleanup.sh
 
. "$DB"/profile/common/scripts/configure-fstab.sh
. "$DB"/profile/common/scripts/install-grub.sh
. "$DB"/profile/common/scripts/mkinitcpio.sh


command -v 'neofetch' > /dev/null 2>&1 && neofetch

[ "$PAUSE_AFTER_DONE" = '1' ] && confirm 'Y ignore' "Confirm to continue" '' 'err "Said no to continuation prompt"; exit 1'


