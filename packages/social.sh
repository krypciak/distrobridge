#!/bin/sh

artix_social_install() {
    echo 'betterdiscordctl discord noto-fonts-cjk noto-fonts-emoji ttf-symbola'
}

arch_social_install() {
    echo 'betterdiscordctl discord noto-fonts-cjk noto-fonts-emoji ttf-symbola'
}

_configure_discord() {
    echo "
    if  ping -c 1 gnu.org > /dev/null 2>&1 && [ \"$MODE\" = 'iso' ]; then
        set +e
        timeout 15s xvfb-run -a discord > /dev/null 2>&1
        betterdiscordctl install > /dev/null 2>&1
        set -e
    fi
    " > "$REPOHUB"/tmp/discordscript
    # Let discord download updates
    doas -u $USER1 timeout 40s sh -c "$REPOHUB"/tmp/discordscript &
}

artix_social_configure() {
    _configure_discord
}

arch_social_configure() {
    _configure_discord
}

