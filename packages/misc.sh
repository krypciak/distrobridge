#!/bin/sh

artix_misc_install() {
    echo 'artix-rebuild-order artools-base artools-iso artools-pkg cups-openrc iso-profiles'
}

arch_misc_install() {
    echo 'cups'
}


artix_misc_configure() {
    sed -i "s|USER_HOME|$USER_HOME|g" /etc/artools/artools-base.conf

    rc-update add cupsd default
}

arch_misc_configure() {
    systemctl enable cups > $OUTPUT 2>&1
}

