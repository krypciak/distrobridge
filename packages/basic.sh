#!/bin/sh

_configure_tldr() {
    info "tldr"
    read -r
    # Generate tealdeer pages
    tldr --update
    tldr tldr > /dev/null 2>&1
    doas -u "$USER1" tldr --update
    doas -u "$USER1" tldr tldr > /dev/null 2>&1
}

_configure_cronie() {
    cp "$DB"/profile/common/configs/cron_user /var/spool/cron/"$USER1"
    chown "$USER1:$USER_GROUP" /var/spool/cron/"$USER1"

    [ "$MODE" = 'iso' ] && echo "@reboot env DISPLAY=:0 ~/home/.config/dotfiles/decrypt-private-data.sh" >> /var/spool/cron/"$USER1"
    
    
    cp "$DB"/profile/common/configs/cron_root /var/spool/cron/root
    sed -i "s|USER_HOME|$USER_HOME|g" /var/spool/cron/root
    chown root:root /var/spool/cron/root
}

artix_basic_install() {
    # ranger
    echo ' antigen artix-archlinux-support atuin autojump-rs bat bat-extras bc bottom cage clang cronie-openrc dog dust dysk fd fish fzf htop hyperfine imagemagick innoextract jq lazygit lsd man-db man-pages moreutils neofetch neovim-symlinks net-tools nodejs ouch p7zip paru-bin pastel pipr-bin pnpm procs pv pyright ripgrep rmtrash syntax-highlighting tealdeer tgpt-bin tmux tokei trash-cli ttf-nerd-fonts-symbols ttyper xorg-server-xvfb xorg-server-xvfb zsh zsh-autosuggestions npm'
    if [ "$LIB32" = '1' ]; then
        echo ' lib32-artix-archlinux-support'
    fi
}

arch_basic_install() {
    echo 'antigen atuin autojump-rs bat bat-extras bc bottom cage clang cronie dog dust dysk fd fish fzf htop hyperfine imagemagick innoextract jq lazygit lsd man-db man-pages moreutils neofetch neovim-symlinks net-tools nodejs ouch p7zip paru-bin pastel pipr-bin pnpm procs pv pyright ripgrep rmtrash syntax-highlighting tealdeer tgpt-bin tmux tokei trash-cli ttf-nerd-fonts-symbols ttyper xorg-server-xvfb xorg-server-xvfb zsh zsh-autosuggestions npm'
}

#python3 -m pip install --user --upgrade pynvim
#pip install black-macchiato

artix_bare_configure() {
    _configure_tldr
    _configure_cronie
    rc-update add cronie default
}


arch_bare_configure() {
    _configure_tldr
    _configure_cronie
    systemctl enable cronie > $OUTPUT 2>&1

}

