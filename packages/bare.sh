#!/bin/sh

_configure_greetd() {
    sed -i "s|USER_HOME|$USER_HOME|g" /etc/greetd/config.toml
    sed -i "s/USER1/$USER1/g" /etc/greetd/config.toml
    cp -r "$USER_HOME/.config/xsessions" /etc/greetd/sessions
    chown "greeter:greeter" -R /etc/greetd
}

artix_bare_install() {
    echo 'btrfs-progs clang dbus dbus-glib dbus-openrc dbus-python doas-sudo-shim dosfstools efibootmgr git greetd-artix-openrc greetd-tuigreet grub mtools networkmanager-openrc openbsd-netcat opendoas openntpd-openrc pacman-contrib perl python python-pip ttf-dejavu ttf-hack unrar unzip util-linux wget zip'
}

arch_bare_install() {
    echo 'btrfs-progs clang dbus dbus dbus-glib dbus-python doas-sudo-shim dosfstools efibootmgr git greetd greetd-tuigreet grub mtools networkmanager openbsd-netcat opendoas openntpd perl python python-pip ttf-dejavu ttf-hack unrar unzip util-linux wget zip'
}

artix_bare_configure() {
    _configure_greetd

    rc-update add greetd default > /dev/null 2>&1
    set +e
    rc-update del agetty.tty1 default > /dev/null 2>&1
    set -e
    rc-update add ntpd default > /dev/null 2>&1
    rc-update add NetworkManager default > /dev/null 2>&1
    
    if [ "$TYPE" = 'iso' ]; then
        cp "$DB"/profile/iso/configs/artix-iso-net /etc/init.d/
        chmod +x /etc/init.d/artix-iso-net
        cp "$DB"/profile/iso/configs/arch-artix-net.sh /etc/
        chmod +x /etc/arch-artix-net.sh
        rc-update add artix-iso-net default > $OUTPUT 2>&1
    fi
}

arch_bare_configure() {
    _configure_greetd

    # apperently greetd already enabled?
    #set +e
    #systemctl disable getty@tty1 > $OUTPUT 2>&1
    #set -e
    #systemctl enable greetd > $OUTPUT 2>&1
    systemctl enable openntpd > $OUTPUT 2>&1
    systemctl enable NetworkManager > $OUTPUT 2>&1

    if [ "$TYPE" = 'iso' ]; then
        cp "$DB"/profile/iso/configs/arch-iso-net.service /usr/lib/systemd/system/
        cp "$DB"/profile/iso/configs/arch-artix-net.sh /etc/
        chmod +x /etc/arch-artix-net.sh
        systemctl enable arch-iso-net > $OUTPUT 2>&1
    fi
}
