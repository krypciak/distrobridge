set -a
USER1="$(ls /home/)"
USER_HOME="$USER_HOME/home"

_git_pull() {
    cd $USER_HOME/.config/dotfiles || eend 1
    git config --global --add safe.directory $USER_HOME/.config/dotfiles
    git pull > /dev/null 2>&1
}
_git_pull &

_pacman_init() {
    pacman -Sy > /dev/null 2>&1
    pacman-key --init > /dev/null 2>&1
    pacman-key --populate > /dev/null 2>&1
}
_pacman_init