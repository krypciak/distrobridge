#!/bin/sh

ISO_OUT_FILENAME="$VARIANT-iso-$(date -u +%Y-%m-%d).iso"
ISO_OUT_FILE="$(echo "$ISO_OUT_DIR/$ISO_OUT_FILENAME" | xargs realpath)"

ISO_WORK_DIR="/mnt/$VARIANT-iso"

ISO_ROOT="$ISO_WORK_DIR/iso"
ISO_LIVEOS="$ISO_ROOT/LiveOS"
ISO_ROOTFS="$ISO_WORK_DIR/rootfs"
INSTALL_DIR="$ISO_ROOTFS"

info "Building iso..."

_wait_dir_mount() {
    set +e
    RETURN="$(umount "$ISO_WAIT_FOR_DIR" 2> /dev/stdout)"
    if [ "$(echo "$RETURN" | grep 'target is busy')" != '' ]; then
        err "${LBLUE}$ISO_WAIT_FOR_DIR${RED} is busy."
        exit 1        
    fi
    set -e
    if [ "$ISO_WAIT_FOR_DIR" != '' ]; then
        info_barr "Waiting for ${LBLUE}${ISO_WAIT_FOR_DIR}${LGREEN} to be available..."
        mount "$ISO_WAIT_FOR_DIR" > /dev/null 2>&1
        while [ "$(grep "$ISO_WAIT_FOR_DIR" /etc/mtab)" = '' ]; do
            sleep 2
            mount "$ISO_WAIT_FOR_DIR"
        done
        info_barr "Mounted."
    fi
}

_wait_dir_mount

 . "$DB"/chroot/prepare-chroot.sh

mkdir -p "$ISO_ROOT"/boot
cp "$ISO_ROOTFS"/boot/initramfs-x86_64.img "$ISO_ROOTFS"/boot/*-ucode.img "$ISO_ROOT"/boot/

. "$DB"/profile/iso/scripts/grub.sh

. "$DB"/profile/iso/scripts/squash.sh

. "$DB"/profile/iso/scripts/mkiso.sh

rm -rf "$ISO_ROOT"

chown "$USER1:$USER1" "$ISO_OUT_FILE"
info "Building ISO done."
echo $ISO_OUT_FILE

if [ "$ISO_COPY_TO_DIR" != '' ]; then
    _wait_dir_mount
    info "Copying the iso to ${LBLUE}${ISO_COPY_TO_DIR}${LGREEN} ..."
    rm -f "$ISO_WAIT_FOR_DIR"/$VARIANT-iso*
    if command -v pv > /dev/null 2>&1; then
        pv "$ISO_OUT_FILE" > "$ISO_WAIT_FOR_DIR/$ISO_OUT_FILENAME"
    else
        cp "$ISO_OUT_FILE" "$ISO_WAIT_FOR_DIR"
    fi
    info "Syncing..."
    sync
    info "Unmounting..."
    umount "$ISO_WAIT_FOR_DIR"
    info "Done."
    info "You can unplug your device now"
fi
