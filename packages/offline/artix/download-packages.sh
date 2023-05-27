#!/bin/sh
set -e
set -a
REPOHUB="$(printf "$(dirname $0)/../../../../" | xargs realpath)"; . "$REPOHUB"/util.sh
DB="$(printf "$REPOHUB/distrobridge" | xargs realpath)"

check_is_root

DIR="$(printf "$(dirname $0)" | xargs realpath)"
VARIANT="$(basename "$DIR")"

info "Updaing system"
pacman --noconfirm -Syu
info "Removing cache"
paccache -rk 1
info "Done"

PACKAGE_GROUPS=""
PACKAGE_GROUPS="$PACKAGE_GROUPS base"      # packages installing pre-chroot
PACKAGE_GROUPS="$PACKAGE_GROUPS bare"      # bare minimum to get into bash shell
PACKAGE_GROUPS="$PACKAGE_GROUPS drivers"   # cpu ucode and gpu drivers
PACKAGE_GROUPS="$PACKAGE_GROUPS basic"     # make the shell usable and preety
PACKAGE_GROUPS="$PACKAGE_GROUPS gui"       # platform independent gui apps
PACKAGE_GROUPS="$PACKAGE_GROUPS audio"     # required for audio to work
PACKAGE_GROUPS="$PACKAGE_GROUPS media"     # ffmpeg, vlc, youtube-dl, yt-dlp
PACKAGE_GROUPS="$PACKAGE_GROUPS browsers"  # dialect, firefox, librewolf, ungoogled-chromium
PACKAGE_GROUPS="$PACKAGE_GROUPS office"    # libreoffice-fresh
PACKAGE_GROUPS="$PACKAGE_GROUPS X11"       # X11 server and utilities like screen locker
PACKAGE_GROUPS="$PACKAGE_GROUPS awesome"   # awesomewm
PACKAGE_GROUPS="$PACKAGE_GROUPS wayland"   # wayland base and utilities like screen locker
PACKAGE_GROUPS="$PACKAGE_GROUPS dwl"       # dwl (wayland wm)
PACKAGE_GROUPS="$PACKAGE_GROUPS coding"    # java, rust, eclipse-java (IDE), git-filter-repo
PACKAGE_GROUPS="$PACKAGE_GROUPS fstools"   # Filesystems, ventoy, testdisk
PACKAGE_GROUPS="$PACKAGE_GROUPS gaming"    # steam. lib32 libraries, lutris, wine, some drivers, java
PACKAGE_GROUPS="$PACKAGE_GROUPS security"  # cpu-x, keepassxc, libfido2, libu2f-server, nmap, openbsd-netcat, yubikey-manager-qt
PACKAGE_GROUPS="$PACKAGE_GROUPS social"    # emojis, discord
PACKAGE_GROUPS="$PACKAGE_GROUPS misc"      # printing (cups)
PACKAGE_GROUPS="$PACKAGE_GROUPS bluetooth" # blueman, bluez, bluetooth support at initcpio
PACKAGE_GROUPS="$PACKAGE_GROUPS virt"      # QEMU
PACKAGE_GROUPS="$PACKAGE_GROUPS android"   # adb
PACKAGE_GROUPS="$PACKAGE_GROUPS baltie"    # https://sgpsys.com/en/whatisbaltie.asp

PACKAGES="$(sh "$DB"/packages/get-package-names.sh)"

if ! command -v pacman > /dev/null 2>&1; then
    err "This script required <user>pacman</user> installed"
    exit 1
fi
if ! command -v pactree > /dev/null 2>&1; then
    err "This script required <user>pactree</user> installed"
    exit 1
fi

PACMAN_CONFIG="$REPOHUB"/tmp/pacman.conf
sed -e "s|DIR|$DIR/pacman|g" "$DIR"/pacman/pacman.conf > "$PACMAN_CONFIG"

BLANK_DB="$REPOHUB"/tmp/blankdb
rm -rf "$BLANK_DB"
mkdir -p "$BLANK_DB"
pacman --config "$PACMAN_CONFIG" --dbpath "$BLANK_DB" -Syy
#pacman-key --init --config "$PACMAN_CONFIG"
#pacman-key --populate --config "$PACMAN_CONFIG"

info "Getting package dependencies"
ALL_PACKAGES="$(echo $PACKAGES | xargs -n 1 pactree -u -l | awk -F "[=<>\t]+" '{print $1}' | sort --unique | xargs)"

# Get proper package names
if [ ! -f "$DIR"/pacman.txt ]; then 
    PACMAN="$(echo $ALL_PACKAGES | tr ' ' '\n' | xargs -I _ doas pacman --color=always -S _ 2>/dev/null | grep 'Packages' | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m/ /g' | awk '{print $1}' | sort --unique | xargs)"
    echo "$PACMAN" > "$DIR"/pacman.txt
else
    PACMAN="$(cat "$DIR"/pacman.txt)" 
fi
 
FILE1="$REPOHUB/tmp/file1.txt"; paru -Pc | awk '{if ($2 == "AUR") { print $1; }}' | sort --unique > "$FILE1"
FILE2="$REPOHUB/tmp/file2.txt"; echo $ALL_PACKAGES | tr ' ' '\n' | sort --unique > "$FILE2"
FILE3="$REPOHUB/tmp/file3.txt"; echo $PACMAN | tr ' ' '\n' | sort --unique > "$FILE3"
FILE4="$REPOHUB/tmp/file4.txt"; comm -12 "$FILE1" "$FILE2" > "$FILE4"

AUR="$(comm -23 "$FILE4" "$FILE3")"

info_garr "Pacman:"
info_barr "$(echo $PACMAN | xargs)"
echo

info_garr "AUR:"
info_barr "$(echo $AUR | xargs)"
echo


if command -v lsb_release > /dev/null 2>&1 && [ "$(lsb_release -si)" = 'Artix' ]; then
    info "Copying official packages"
    mkdir -p "$DIR"/packages
    
    GREP_OFFICIAL_COPY="$(echo $PACMAN | tr ' ' '\n' | awk '{print "-e ^" $1 "-"}' | xargs)"
    cd /var/cache/pacman/pkg
    # shellcheck disable=2010
    ls -1 -- *.pkg.tar.zst | grep -E -e $GREP_OFFICIAL_COPY | awk '{print "/var/cache/pacman/pkg/" $1}' | xargs -I _ cp _ "$DIR"/packages/
    info "Done"
else
    warn "Distro is not '$VARIANT', downloading insted"
fi


info "Downloading missing packages"
pacman --config "$PACMAN_CONFIG" --noconfirm --downloadonly --dbpath "$BLANK_DB" --cachedir "$DIR"/packages -S $PACMAN
paccache -c "$DIR"/packages -rk 1 

chown -R "$USER1:$USER1" "$DIR"/packages
rm -rf "$BLANK_DB"

info "Copying AUR packages"
GREP_AUR_COPY="$(echo $AUR | tr ' ' '\n' | awk '{print "-e " $1 }' | xargs)"
# shellcheck disable=2010
ls -1 /home/"$USER1"/.cache/paru/clone/ | grep -E -e $GREP_AUR_COPY | awk "{printf(\"/home/$USER1/.cache/paru/clone/%s/\", \$1); system(\"pacman -Qi \$AUR | grep -E 'Version|Name|Architecture' | awk '{print \$3}' | grep -A 2 \" \$1 \" | xargs | tr ' ' '-' | head -c -1\"); printf(\".pkg.tar.zst\n\")}" | xargs -I _ cp _ $DIR/packages/

info "Creating a repo"
rm -f $DIR/packages/offline.db.tar.gz
rm -f "$DIR"/packages/offline.db
repo-add "$DIR"/packages/offline.db.tar.gz "$DIR"/packages/*.pkg.tar.zst --quiet

chown -R "$USER1:$USER1" "$DIR"
