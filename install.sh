#!/bin/sh
set -e
set -a

REPOHUB="$(printf "$(dirname $0)/../" | xargs realpath)"; . "$REPOHUB"/util.sh
# distro bridge dir
DB="$(printf "$REPOHUB/distrobridge" | xargs realpath)"

_help() {
    printf "Usage:\n"
    printf "    -h --help              Displays this message\n"
    printf "    -y --noconfim          Skips confirmations\n"
    printf "    -q  --quiet            Silence a lot of output\n"
    printf "    -m --mode MODE         Installation mode: [ disk, dir, live, iso ]\n"
    printf "    -v --variant VARIANT   [ artix, arch ]\n"
    printf "       --offline           Install packages from disk (if available)\n"
    printf "\n"
    printf " --type=disk options:\n"
    printf "       --device DEVICE     Device to install to. Eg. /dev/sda\n"
    printf "\n"
    printf " --type=dir options:\n"
    printf "       --dir DIR           Destination install directory\n"
    printf "\n"
    printf " --type=iso options:\n"
    printf "       --iso ISO           Destination directory for .iso image\n"
    printf "       --iso-copy-to DIR   Copy the iso to that dir and delete all previous variant iso's\n"
    printf "       --wait-for-dir DIR  Dont start iso build until that dir is mounted\n"
    exit 1
}

check_is_root

QUIET=0
TYPE='normal'
NET='online'
OUTPUT='/dev/stdout'

handle_args "\
-y|--noconfirm=export YOLO=1,\
-q|--quiet=export QUIET=1; export OUTPUT='/dev/null',\
-v|--variant:R=export VARIANT=\"\$2\",\
-m|--mode:R=export MODE=\"\$2\";,\
--offline=export NET='offline',\
--device:=export DEVICE=\"\$2\",\
--dir:=export INSTALL_DIR=\"\$2\",\
--iso:=export ISO_OUT_DIR=\"\$2\",\
--iso-copy_to:=export ISO_COPY_TO_DIR=\"\$2\",\
--wait-for-dir:=export ISO_WAIT_FOR_DIR=\"\$2\",\
" "$@"
if [ "$MODE" = 'iso' ]; then 
    export TYPE='iso';
    if [ "$ISO_OUT_DIR" = '' ]; then err "Missing argument (required for --mode=iso): --iso"; _help; fi
fi
if [ "$MODE" = 'disk' ]; then 
    if [ "$DEVICE" = '' ]; then err "Missing argument (required for --mode=disk): --device"; _help; fi
fi
if [ "$MODE" = 'dir' ]; then 
    if [ "$INSTALL_DIR" = '' ]; then err "Missing argument (required for --mode=dir): --dir"; _help; fi
fi

info "Mode: $MODE  Variant: $VARIANT  Type: $TYPE  Net: $NET"



if [ "$VARIANT" = 'artix' ]; then
    if [ "$TYPE" = 'normal' ]; then
        VARIANT_NAME="Artix"
    elif [ "$TYPE" = 'iso' ]; then
        VARIANT_NAME="Artix ISO"
    fi

elif [ "$VARIANT" = 'arch' ]; then
    if [ "$TYPE" = 'normal' ]; then
        VARIANT_NAME="Arch"
    elif [ "$TYPE" = 'iso' ]; then
        VARIANT_NAME="Arch ISO"
    fi
else
    err 'Invalid variant.'; _help
fi

if [ "$MODE" = 'iso' ]; then
    if [ ! -f "$DB"/vars.conf.iso.sh ]; then
        err "Config file <path>vars.conf.iso.sh</path> doesn't exist."
        exit 3
    fi
    . "$DB"/vars.conf.iso.sh
else
    if [ ! -f "$DB/vars.conf.sh" ]; then
        err "Config file <path>vars.conf.sh</path> doesn't exist."
        exit 3
    fi
    . "$DB"/vars.conf.sh
fi


if [ "$MODE" = 'live' ]; then
    . "$DB"/live/live.sh

elif [ "$MODE" = 'iso' ]; then
    . "$DB"/iso.sh

elif [ "$MODE" = 'disk' ]; then
    . "$DB"/disk.sh

elif [ "$MODE" = 'dir' ]; then
    . "$DB"/chroot.sh
fi


