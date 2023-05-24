#!/bin/sh

_setup_cmus_notifications() {
    set +e
    ping -c 1 gnu.org > /dev/null 2>&1 || return

    export PATH="$PATH:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
    cd /tmp
    info "Installing HTML::Entities using cpan..."
    yes yes | cpan -T HTML::Entities > /dev/null 2>&1
    git clone https://github.com/dcx86r/cmus-notify > /dev/null 2>&1
    cd cmus-notify
    sh installer.sh install
    set -e
}

artix_audio_install() {
    echo 'alsa-utils cmus-git perl playerctl pulseaudio pulseaudio-alsa'
}

arch_audio_install() {
    echo 'alsa-utils cmus-git perl playerctl pulseaudio pulseaudio-alsa'
}


artix_audio_configure() {
    _setup_cmus_notifications
}

arch_audio_configure() {
    _setup_cmus_notifications
}




