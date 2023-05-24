#!/bin/sh

_make_dwl() {
    info 'Compiling dwl'
    cd "$USER_HOME"/.config/dwl/dwl-dotfiles/
    doas -u "$USER1" git switch main
    doas -u "$USER1" git remote add upstream https://github.com/djpohly/dwl
    doas -u "$USER1" git reset --hard HEAD

    if [ "$PORTABLE" = '1' ]; then
        # Disable keepassxc, tutanota, blueman applet, wlr-output and gammastep startup
        str='"\[ \\"\$(pgrep keepassxc';        sed -i "s|$str|//$str|g" config.h
        str='"\[ \\"\$(pgrep tutanota';         sed -i "s|$str|//$str|g" config.h
        str='"gammastep -r"';                   sed -i "s|$str|//$str|g" config.h
        str='"blueman-applet"';                 sed -i "s|$str|//$str|g" config.h
        str='{ "HDMI-A-1"';                     sed -i "s|$str|//$str|g" config.h
        str='{ "DP-1"';                         sed -i "s|$str|//$str|g" config.h
        str='\"alacritty --class cmus';         sed -i "s|$str|//$str|g" config.h
        str='\"wlr-randr --output DP-1 --off';  sed -i "s|$str|//$str|g" config.h
    fi

    if [ "$MODE" = 'iso' ]; then
        # Run private archive decryption prompt at startup
        str1='\t"sh $HOME/.config/dotfiles/decrypt-private-data.sh",'
        str='"fnott",\n'; sed -i "s|$str|$str$str1|g" config.h
    fi

    doas -u "$USER1" make
}

_make_somebar() {
    info 'Compiling somebar'

    cd "$USER_HOME"/.config/dwl/somebar/
    doas -u "$USER1" git switch master
    doas -u "$USER1" git remote add upstream https://git.sr.ht/~raphi/somebar
    doas -u "$USER1" git reset --hard HEAD
    doas -u "$USER1" meson build
    cd build
    doas -u "$USER1" ninja
}

_make_someblocks() {
    info 'Compiling someblocks'

    cd "$USER_HOME"/.config/dwl/someblocks
    doas -u "$USER1" git switch master
    doas -u "$USER1" git remote add upstream https://git.sr.ht/~raphi/someblocks
    doas -u "$USER1" git reset --hard HEAD
    doas -u "$USER1" make
}

_make_dpms() {
    info 'Compiling dpms'

    cd "$USER_HOME"/.config/dwl/dpms-off
    doas -u "$USER1" git switch master
    doas -u "$USER1" cargo build --release
    doas -u "$USER1" git reset --hard HEAD
    rm -rf "$USER_HOME"/.config/dotfiles/dotfiles/dwl/dpms-off/target/release/deps
    rm -rf "$USER_HOME"/.config/dotfiles/dotfiles/dwl/dpms-off/target/release/build
}

_configure_dwl() {
    set +e
    _make_dwl
    _make_somebar
    _make_someblocks
    #_make_dpms
    set -e
    chown "$USER1:$USER_GROUP" -R "$USER_HOME"/.config/dwl
}


artix_dwl_install() {
    echo 'meson ninja xdg-desktop-portal-wlr'
}

arch_dwl_install() {
    echo 'meson ninja xdg-desktop-portal-wlr'
}

artix_dwl_configure() {
    _configure_dwl
}

arch_dwl_configure() {
    _configure_dwl
}

