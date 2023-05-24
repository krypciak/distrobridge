#!/bin/sh

_init_browsers() {
    # Let firefox extensions init
    doas -u "$USER1" timeout 10s librewolf --headless > /dev/null 2>&1 &
    doas -u "$USER1" timeout 10s firefox --headless > /dev/null 2>&1 &
}

artix_browsers_install() {
    echo 'dialect firefox librewolf ungoogled-chromium'
}

arch_browsers_install() {
    echo 'dialect firefox'
}


artix_browsers_configure() {
    _init_browsers
}

arch_browsers_configure() {
    _init_browsers
}

