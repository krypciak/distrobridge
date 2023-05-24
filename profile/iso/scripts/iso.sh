#!/bin/sh
[ "$REPOHUB" = '' ] && err '$REPOHUB variable not set. This script is not ment to be run by the user.' && exit 1
set -a
set -e

REPOHUB="$(printf "$(dirname $0)/../" | xargs realpath)"; . "$REPOHUB"/util.sh; DB="$(printf "$REPOHUB/distrobridge" | xargs realpath)"

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

[ -f "$DB"/profile/"$VARIANT"/scripts/iso.sh ] && . "$DB"/profile/"$VARIANT"/scripts/iso.sh

. "$DB"/profile/common/scripts/cleanup.sh

cp "$DB"/profile/iso/root/etc/doas.conf /etc/doas.conf


printf "#000000" > $REPOHUB/dotfiles/user/.config/wallpapers/selected

echo 'export WINIT_X11_SCALE_FACTOR=1.2' >> $USER_HOME/.config/at-login.sh

. "$DB"/iso/mkinitcpio.sh


info "neofetch!"
command -v 'neofetch' > /dev/null 2>&1 && neofetch

[ "$PAUSE_AFTER_DONE" = '1' ] && confirm 'Y ignore' "Confirm to continue" '' 'err "Said no to continuation prompt"; exit 1'
 
