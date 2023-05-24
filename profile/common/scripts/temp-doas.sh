#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

info "Creating temporary doas config"
echo "permit nopass setenv { YOLO USER1 USER_GROUP PACMAN_ARGUMENTS PARU_ARGUMENTS PACKAGE_LIST BASH_FUNC__configure_discord1%% } root" > /etc/doas.conf
echo "permit nopass setenv { YOLO USER1 USER_GROUP PACMAN_ARGUMENTS PARU_ARGUMENTS PACKAGE_LIST BASH_FUNC__configure_discord1%% } $USER1" >> /etc/doas.conf

