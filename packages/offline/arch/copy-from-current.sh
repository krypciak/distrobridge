#!/bin/bash

set -a

if [ "$(whoami)" != 'root' ]; then
    echo This script needs to be run as root.
    exit 1
fi


_PWD="$(pwd)"
_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd | xargs realpath )
OFFLINE_DIR=$(dirname $_DIR)
PACKAGES_DIR=$(dirname $OFFLINE_DIR)


#echo 'Updaing system'
#pacman --noconfirm -Syu
#echo 'Removing cache'
#paccache -rk 1
#echo -e 'Done.\n\n'

PACKAGE_GROUPS=(
    'base'
    'bare'
    'drivers'   
    'basic'     
    'gui'       
    'audio'     
    'media'     
    'browsers'  
    'office'    
    'X11'       
    'awesome'   
    'wayland'   
    'dwl'       
    'coding'    
    'fstools'   
    'gaming'    
    'security'  
    'social'    
    'misc'      
    'bluetooth' 
    'virt'      
    'android'   
    'baltie'    
)
VARIANT='arch'
PACKAGES="$(sh $PACKAGES_DIR/get-package-names.sh)"


rm -f /tmp/aurpackages
rm -rf /tmp/blankdb
mkdir -p /tmp/blankdb

doas cp $_DIR/pacman.conf /tmp/pacman.conf
sed -e "s|DIR|$_DIR|g" -i /tmp/pacman.conf

pacman --config /tmp/pacman.conf --dbpath /tmp/blankdb -Sy

ALL_PACKAGES="$(echo $PACKAGES | xargs -n 1 pactree --config /tmp/pacman.conf --dbpath /tmp/blankdb -s -u -l | awk -F "[=<>\t]+" '{print $1}' | sort --unique | xargs)"

# Get proper package names
if [ ! -f $_DIR/pacman.txt ]; then 
    PACMAN="$(echo $ALL_PACKAGES | tr ' ' '\n' | xargs -I _ doas pacman --config /tmp/pacman.conf --color=always -S _ 2>/dev/null | grep 'Packages' | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m/ /g' | awk '{print $1}' | sort --unique | xargs)"
    echo $PACMAN > $_DIR/pacman.txt
else
    PACMAN="$(cat $_DIR/pacman.txt | xargs)" 
fi
    
AUR="$(comm -23 <(comm -12 <(paru --config /tmp/pacman.conf -Pc | awk '{if ($2 == "AUR") { print $1; }}' | sort --unique ) <(echo $ALL_PACKAGES | tr ' ' '\n' | sort --unique)) <(echo $PACMAN | tr ' ' '\n' | sort --unique))"

echo -e '\nAUR:'
echo $AUR
echo -e '\n'

echo -e '\nPacman:'
echo $PACMAN
echo -e '\n'


#echo -e '\nCopying official packages...'
#mkdir -p $_DIR/packages
#GREP_OFFICIAL_COPY="$(echo $PACMAN | tr ' ' '\n' | awk '{print "-e ^" $1 "-"}' | xargs)"
#cd /var/cache/pacman/pkg
#ls *.pkg.tar.zst -1 | grep -E -e $GREP_OFFICIAL_COPY | awk '{print "/var/cache/pacman/pkg/" $1}' | xargs -I _ cp _ $_DIR/packages/
#echo -e 'Done.\n'


echo 'Downloading missing packages...'
#doas rm -rf /tmp/blankdb
mkdir -p /tmp/blankdb

doas sed -i 's|ParallelDownloads = |ParallelDownloads = 10 \n#|' /tmp/pacman.conf
#doas pacman --config /tmp/pacman.conf --noconfirm -Syw --dbpath /tmp/blankdb --cachedir . $PACMAN
doas pacman --config /tmp/pacman.conf --noconfirm --downloadonly -S --dbpath /tmp/blankdb --cachedir $_DIR/packages/ $PACMAN

doas chown -R $USER1:$USER1 $_DIR/packages
doas rm -rf /tmp/blankdb

echo 'Copying AUR packages...'
GREP_AUR_COPY="$(echo $AUR | tr ' ' '\n' | awk '{print "-e " $1 }' | xargs)"
ls /home/$USER1/.cache/paru/clone/ -1 | grep -E -e $GREP_AUR_COPY | awk "{printf(\"/home/$USER1/.cache/paru/clone/%s/\", \$1); system(\"pacman -Qi \$AUR | grep -E 'Version|Name|Architecture' | awk '{print \$3}' | grep -A 2 \" \$1 \" | xargs | tr ' ' '-' | head -c -1\"); printf(\".pkg.tar.zst\n\")}" | xargs -I _ cp _ $_DIR/packages/


rm -f "$_DIR/packages/ttf-nerd-fonts-symbols-2048-em-2.3.3-1-any.pkg.tar.zst"

echo 'Creating a repo...'
#rm -f $_DIR/packages/offline.db.tar.gz
rm -f $_DIR/packages/offline.db
repo-add $_DIR/packages/offline.db.tar.gz $_DIR/packages/*.pkg.tar.zst --quiet

cd "$PWD"

chown -R $USER1:$USER1 $_DIR/
