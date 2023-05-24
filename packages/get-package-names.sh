#!/bin/sh
set -a
set -e

PACKAGES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd | xargs realpath )


if [ -z "$PACKAGE_GROUPS" ]; then
    PACKAGE_GROUPS=(
        'base'      # packages installing pre-chroot
        'bare'      # bare minimum to get into bash shell
        'drivers'   # cpu ucode and gpu drivers
        'basic'     # make the shell usable and preety
        'gui'       # platform independent gui apps
        'audio'     # required for audio to work
        'media'     # ffmpeg, vlc, youtube-dl, yt-dlp
        'browsers'  # dialect, firefox, librewolf, ungoogled-chromium
        'office'    # libreoffice-fresh
        'X11'       # X11 server and utilities like screen locker
        'awesome'   # awesomewm
        'wayland'   # wayland base and utilities like screen locker
        'dwl'       # dwl (wayland wm)
        'coding'    # java, rust, eclipse-java (IDE), git-filter-repo
        'fstools'   # Filesystems, ventoy, testdisk
        'gaming'    # steam. lib32 libraries, lutris, wine, some drivers, java
        'security'  # cpu-x, keepassxc, libfido2, libu2f-server, nmap, openbsd-netcat, yubikey-manager-qt
        'social'    # emojis, discord
        'misc'      # printing (cups)
        'bluetooth' # blueman, bluez, bluetooth support at initcpio
        'virt'      # QEMU
        'android'   # adb
        'baltie'    # https://sgpsys.com/en/whatisbaltie.asp
    )
fi

if [ -z "$VARIANT" ]; then VARIANT='artix'; fi
if [ -z "$ALL_DRIVERS" ]; then ALL_DRIVERS='1'; fi
if [ -z "$LIB32" ]; then LIB32='1'; fi
if [ -z "$KERNEL" ]; then KERNEL='linux-zen'; fi

PACKAGE_LIST=''
GROUP_LIST=''
for group in "${PACKAGE_GROUPS[@]}"; do
    source $PACKAGES_DIR/${group}.sh
    INSTALL_FUNC="${VARIANT}_${group}_install"
    if command -v "$INSTALL_FUNC" &> /dev/null; then
        GROUP_LIST="$GROUP_LIST $group"
        PACKAGE_LIST="$PACKAGE_LIST $($INSTALL_FUNC) "
    fi
done


echo $PACKAGE_LIST | tr ' ' '\n' | sort --unique | xargs
