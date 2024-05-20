#!/bin/sh

_configure_limits() {
    sed -i "s/USER1/$USER1/g" /etc/security/limits.conf
}

artix_gaming_install() {
    echo 'alsa-lib alsa-plugins gamemode gamescope giflib gnutls gst-plugins-base-libs gtk3 jdk17-openjdk jdk8-openjdk jdk-openjdk lib32-alsa-lib lib32-alsa-plugins lib32-gamemode lib32-giflib lib32-giflib lib32-gnutls lib32-gst-plugins-base-libs lib32-gtk3 lib32-libgcrypt lib32-libgpg-error lib32-libjpeg-turbo lib32-libldap lib32-libpng lib32-libpulse lib32-libpulse lib32-libva lib32-libxcomposite lib32-libxcomposite lib32-libxinerama lib32-libxinerama lib32-libxslt lib32-mpg123 lib32-mpg123 lib32-ncurses lib32-ocl-icd lib32-openal lib32-openal lib32-opencl-icd-loader lib32-sqlite lib32-v4l-utils lib32-v4l-utils lib32-vulkan-icd-loader libgcrypt libgpg-error libjpeg-turbo libldap libpng libpulse libva libxcomposite libxinerama libxslt lutris mpg123 ncurses ocl-icd openal prismlauncher-qt5-bin sqlite steam v4l-utils vulkan-icd-loader wine-staging wine-staging'
}

arch_gaming_install() {
    echo 'alsa-lib alsa-plugins gamemode gamescope giflib gnutls gst-plugins-base-libs gtk3 jdk17-openjdk jdk8-openjdk jdk-openjdk lib32-alsa-lib lib32-alsa-plugins lib32-gamemode lib32-giflib lib32-giflib lib32-gnutls lib32-gst-plugins-base-libs lib32-gtk3 lib32-libgcrypt lib32-libgpg-error lib32-libjpeg-turbo lib32-libldap lib32-libpng lib32-libpulse lib32-libpulse lib32-libva lib32-libxcomposite lib32-libxcomposite lib32-libxinerama lib32-libxinerama lib32-libxslt lib32-mpg123 lib32-mpg123 lib32-ncurses lib32-ocl-icd lib32-openal lib32-openal lib32-opencl-icd-loader lib32-sqlite lib32-v4l-utils lib32-v4l-utils lib32-vulkan-icd-loader libgcrypt libgpg-error libjpeg-turbo libldap libpng libpulse libva libxcomposite libxinerama libxslt lutris mpg123 ncurses ocl-icd openal prismlauncher-qt5-bin sqlite steam v4l-utils vulkan-icd-loader wine-staging wine-staging'
}

artix_gaming_configure() {
    _configure_limits
    archlinux-java set java-17-openjdk
}


arch_gaming_configure() {
    _configure_limits
    archlinux-java set java-17-openjdk
}

