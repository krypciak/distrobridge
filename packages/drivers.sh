#!/bin/sh

_artix_arch_driver_install() {
    DRIVER_LIST='mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader vulkan-headers mkinitcpio-firmware '

    if [ "$ALL_DRIVERS" = '0' ]; then
        if [ "$CPU" = 'amd' ]; then DRIVER_LIST="$DRIVER_LIST amd-ucode"
        elif [ "$CPU" = 'intel' ]; then DRIVER_LIST="$DRIVER_LIST intel-ucode"
        else err "Invalid CPU: <user>$CPU</user>"; fi
    
        if [ "$GPU" = 'amd' ]; then 
            # amdvlk lib32-amdvlk
            DRIVER_LIST="$DRIVER_LIST xf86-video-amdgpu amdvlk lib32-amdvlk vulkan-radeon lib32-vulkan-radeon"
            cp $COMMON_CONFIGS_DIR/20-amdgpu.conf /etc/X11/xorg.conf.d/
        elif [ "$GPU" = 'ati' ]; then DRIVER_LIST="$DRIVER_LIST xf86-video-ati amdvlk lib32-amdvlk vulkan-radeon lib32-vulkan-radeon"
        elif [ "$GPU" = 'intel' ]; then DRIVER_LIST="$DRIVER_LIST xf86-video-intel vulkan-intel lib32-vulkan-intel"
        elif [ "$GPU" = 'nvidia' ]; then DRIVER_LIST="$DRIVER_LIST xf86-video-nouveau"
        else err "Invalid GPU: $GPU"; fi
    
    else
        DRIVER_LIST="$DRIVER_LIST amd-ucode intel-ucode"
        DRIVER_LIST="$DRIVER_LIST xf86-input-vmmouse xf86-video-amdgpu xf86-video-ati xf86-video-dummy xf86-video-fbdev xf86-video-intel xf86-video-nouveau xf86-video-vesa xf86-video-vmware vulkan-radeon"
    fi
    echo $DRIVER_LIST
}

artix_drivers_install() {
    _artix_arch_driver_install
}

arch_drivers_install() {
    _artix_arch_driver_install
}
