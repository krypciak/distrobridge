#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1
set -e
set -a

EXCLUDE_FLAG=''

if [ "$COPY_OFFLINE_PACKAGES" = '0' ]; then
    OFFLINE_DIR="$INSTALL_DIR/home/$USER1/home/.config/dotfiles/install/packages/offline"
    EXCLUDE_FLAG='--exclude=install/packages/offline/'
    mkdir -p "$OFFLINE_DIR"
fi

MOUNT_ACTION='true'
UMOUNT_ACTION='true'

if [ "$COPY_OFFLINE_PACKAGES" = '0' ]; then
    MOUNT_ACTION="mount --bind $DB/packages/offline $OFFLINE_DIR"
    UMOUNT_ACTION="umount -R $OFFLINE_DIR"
fi

_USER_CONFIG_DIR=\"$INSTALL_DIR$FAKE_USER_HOME/.config\"

PRE_CHROOT_ACTION="
set -e
. $DB/profile/$VARIANT/scripts/strap-packages.sh
confirm 'Y' \"Chroot into <path>$INSTALL_DIR</path>?\" '' 'err \"Said no to continuation prompt\"; exit 1'
mkdir -p $_USER_CONFIG_DIR
if [ '$REPOHUB' = '' ]; then
    warn \"\$REPOHUB is not set. Continuing limited installation\"
    info \"Copying <path>distrobridge</path> to <path>$_USER_CONFIG_DIR/repohub/distrobridge</path>\"
    mkdir -p $_USER_CONFIG_DIR/repohub
    rsync -a --exclude='install/artix/' $EXCLUDE_FLAG $DB $_USER_CONFIG_DIR/
else
    info \"Copying <path>repohub</path> to <path>$_USER_CONFIG_DIR/repohub</path>\"
    rsync -a --exclude='install/artix/' $EXCLUDE_FLAG $REPOHUB $_USER_CONFIG_DIR
    rm -rf $_USER_CONFIG_DIR/repohub/dotfiles/user/private $_USER_CONFIG_DIR/repohub/dotfiles/user/private.old
fi
info \"Chrooting into <path>$INSTALL_DIR</path>...\"
"

if [ "$MODE" = 'normal' ]; then
    _SCRIPT="$USER_HOME"/home/.config/repohub/distrobridge/profile/common/scripts/live.sh
else
    _SCRIPT="$USER_HOME"/home/.config/repohub/distrobridge/profile/iso/scripts/iso.sh
fi

SCRIPTS_DIR="$USER_HOME/home/.config/repohub/distrobridge/profile/iso/scripts"

CMD="export $(env | grep -E "^(DB|MODE|VARIANT|VARIANT_NAME|TYPE|NET)" | xargs) REPOHUB=$USER_HOME/home/.config/repohub; sh $_SCRIPT"
echo "$CMD" > "$INSTALL_DIR"/chrootscript.sh
CMD="/bin/sh /chrootscript.sh"
. "$DB"/chroot/chroot.sh
rm -f "$INSTALL_DIR"/chrootscript.sh
