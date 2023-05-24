#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

unmount() {
    sync
    swapoff -a > /dev/null 2>&1
    umount -q "$BOOT_PART" > /dev/null 2>&1
    umount -Rq "$INSTALL_DIR" > /dev/null 2>&1
    swapoff "$LVM_DIR/swap" > /dev/null 2>&1
    lvchange -an "$LVM_GROUP_NAME" > /dev/null 2>&1
    cryptsetup close "$CRYPT_FILE" > /dev/null 2>&1
    umount -q "$CRYPT_FILE" > /dev/null 2>&1
    sync
}

fdisk -l "$DISK" > $OUTPUT
info_garr "Partitioning the disk..."
confirm 'N barr' "Start partitioning <path>$DISK</path>? $RED(DATA WARNING)" '' 'err "Said no to continuation prompt"; exit 1'
info_brr "Unmouting"

unmount
vgremove -f "$LVM_GROUP_NAME" > /dev/null 2>&1
unmount

(
echo g # set partitioning scheme to GPT
echo n # Create BOOT partition
echo 1 # partition number 1
echo   # default - start at beginning of disk 
echo +$BOOT_SIZE
echo t # set partition type
echo 1 # to EFI partition
echo n # Create LVM partition
echo 2 # partion number 2
echo " "  # default, start immediately after preceding partition
if [ "$ENCRYPT" = '1' ]; then
    if [ "$CRYPT_SIZE" = '' ]; then 
        echo 
    else 
        echo +$CRYPT_SIZE
    fi
else
    if [ "$LVM_SIZE" = '' ]; then 
        echo 
    else 
        echo +$LVM_SIZE
    fi
fi
echo t # set partition type
echo 2
echo 43 # to LV
echo p # print the in-memory partition table
echo w # write changes
echo q # quit
) | fdisk $DISK > $OUTPUT

info "Partitioning finished."

mkdir -p "$INSTALL_DIR"

if [ "$ENCRYPT" = '1' ]; then
    info_garr "Setting up encryption on <path>$CRYPT_PART</path>"
    confirm 'N barr' "Setup luks on <path>$CRYPT_PART</path>? $RED(DATA WARNING)" '' 'err "Said no to continuation prompt"; exit 1'
    if [ "$LUKS_PASSWORD" != '' ]; then
        info_barr "Automaticly filling password..."

        if ! echo "$LUKS_PASSWORD" | cryptsetup luksFormat $LUKSFORMAT_ARGUMENTS "$CRYPT_PART" > $OUTPUT; then
            err "LUKS error"; exit 1
        fi

        info_barr "Opening <path>$CRYPT_PART</path> as <path>$CRYPT_NAME</path"
        info_barr "Automaticly filling password..."
        if ! echo "$LUKS_PASSWORD" | cryptsetup open "$CRYPT_PART" "$CRYPT_NAME" > $OUTPUT; then
            err "LUKS error"; exit 1
        fi
    else
        while true; do
            
            if cryptsetup luksFormat $LUKSFORMAT_ARGUMENTS "$CRYPT_PART"; then
                break
            fi
            confirm 'Y barr ignore' 'Do you wanna retry?' '' ''
        done    
        
        while true; do
            info_barr "Opening <path>$CRYPT_PART</path> as <path>$CRYPT_NAME</path"
            if cryptsetup open "$CRYPT_PART" "$CRYPT_NAME"; then
                break
            fi
            confirm 'Y barr ignore' 'Do you wanna retry?' '' ''
        done
    fi
    LVM_TARGET_FILE="$CRYPT_FILE"
else
    LVM_TARGET_FILE="$LVM_PART"
fi

info "Setting up LVM on <path>$LVM_PART</path>"

info "Creating LVM group <path>$LVM_GROUP_NAME</path>"
pvcreate --force $LVM_TARGET_FILE > $OUTPUT || err "LVM error" && exit
vgcreate $LVM_GROUP_NAME $LVM_TARGET_FILE > $OUTPUT || err "LVM error" && exit

info_garr "Creating volumes"
if [ "$ENABLE_SWAP" = '1' ]; then
    info_barr "Creating SWAP"
    lvcreate -C y -L $SWAP_SIZE $LVM_GROUP_NAME -n swap > $OUTPUT || err "LVM error" && exit
fi
info_barr "Creating ROOT of size $ROOT_SIZE"
lvcreate -C y -L $ROOT_SIZE $LVM_GROUP_NAME -n root > $OUTPUT || err "LVM error" && exit

info_barr "Creating HOME of size 100%FREE"
lvcreate -C y -l 100%FREE $LVM_GROUP_NAME -n home > $OUTPUT || err "LVM error" && exit

info_garr "Formatting volumes"
if [ "$ENABLE_SWAP" = '1' ]; then
    info_barr "SWAP"
    mkswap -L swap $LVM_DIR/swap > $OUTPUT || err "LVM error" && exit
fi

info_barr "ROOT"
$ROOT_FORMAT_COMMAND > $OUTPUT 2>&1 || err "LVM error" && exit

info_barr "HOME"
$HOME_FORMAT_COMMAND > $OUTPUT 2>&1 || err "LVM error" && exit

info_barr "BOOT"
$BOOT_FORMAT_COMMAND > $OUTPUT 2>&1 || err "LVM error" && exit

info_garr "Mounting volumes"
info_barr "<path>$LVM_DIR/root</path> to <path>$INSTALL_DIR</path>"
mount "$LVM_DIR/root" "$INSTALL_DIR" > $OUTPUT || err "LVM error" && exit

info "<path>$LVM_DIR/home</path> to <path>$INSTALL_DIR/home/$USER1</path>"
mkdir -p "$INSTALL_DIR/home/$USER1"
mount "$LVM_DIR/home" "$INSTALL_DIR/home/$USER1" > $OUTPUT || err "LVM error" && exit

info "<path>$BOOT_PART</path> to <path>$BOOT_DIR</path>"
mkdir -p "$BOOT_DIR"
mount "$BOOT_PART" "$BOOT_DIR" > $OUTPUT || err "LVM error" && exit

if [ "$ENABLE_SWAP" = '1' ]; then
    info "Turning swap on"
    swapon "$LVM_DIR/swap" > $OUTPUT || err "LVM error" && exit
fi

. "$DB"/chroot/prepare-chroot.sh

unmount
if [ "$AUTO_REBOOT" = '0' ]; then
    confirm 'Y ignore' "Reboot?" '' 'exit 1;'
fi
reboot

