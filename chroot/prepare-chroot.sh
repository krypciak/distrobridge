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
confirm 'Y' \"Chroot into ${INSTALL_DIR}?\" '' 'err \"Said no to continuation prompt\"; exit 1'
mkdir -p $_USER_CONFIG_DIR
if [ \"$REPOHUB\" = '' ]; then
    info \"Copying <path>repohub</path> to <path>$_USER_CONFIG_DIR/dotfiles</path>\"
    rsync -a --exclude='install/artix/' $EXCLUDE_FLAG $DOTFILES_DIR $_USER_CONFIG_DIR/
else
    warn '\$REPOHUB is not set. Continuing limited installation
    info \"Copying <path>distrobridge</path> to <path>$_USER_CONFIG_DIR/dotfiles</path>\"
    rsync -a --exclude='install/artix/' $EXCLUDE_FLAG $DOTFILES_DIR $_USER_CONFIG_DIR/
fi
"

if [ "$MODE" = 'normal' ]; then
    _SCRIPT="$USER_HOME"/home/.config/repohub/distrobridge/profile/iso/scripts/iso.sh
else
    _SCRIPT="$USER_HOME"/home/.config/repohub/distrobridge/profile/live/scripts/live.sh
fi

SCRIPTS_DIR="$USER_HOME/home/.config/dotfiles/install/scripts"

CMD="/bin/sh -c 'export $(env | grep -E '^(CONF_FILES_DIR|SCRIPTS_DIR|MODE|VARIANT|VARIANT_NAME|TYPE|NET)' | xargs); sh $_SCRIPT'"
. "$DB"/chroot/chroot.sh
