#!/bin/sh
[ "$DB" = '' ] && err '$DB variable not set. This script is not ment to be run by the user.' && exit 1

chown -R "$USER1:$USER_GROUP" "$USER_HOME"

if [ "$INSTALL_DOTFILES" = '1' ]; then
    if [ "$REPOHUB" = '' ]; then
        warn "\$REPOHUB is not set. Skipping dotfiles installation"
    else
        info "Installing dotfiles for user <user>$USER1</user>"
        rm -rf "$USER_HOME"/.config
        doas -u "$USER1" sh "$REPOHUB"/dotfiles/install-user.sh > $OUTPUT

        info "Installing dotfiles for <user>root</user>"
        . "$REPOHUB"/dotfiles/install-root.sh > $OUTPUT

        if [ "$INSTALL_PRIVATE_DOTFILES" = '1' ]; then
            confirm "Install private dotfiles?"
            export GPG_AGENT_INFO=""
            . "$REPOHUB"/dotfiles/decrypt-private-data.sh > $OUTPUT 2>&1
        fi
    fi
fi

info 'Generating fish completions'
fish --command "fish_update_completions" > /dev/null 2>&1 &
doas -u "$USER1" fish --command "fish_update_completions" > /dev/null 2>&1 &

wait $(jobs -p)
