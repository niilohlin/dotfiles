#!/bin/zsh

# This script provides a way to navigate through the directory stack using
# the "Ctrl-O" and "Ctrl-I" keys in vi mode.

if [ -z $DIRSTACKSIZE ]; then
    DIRSTACKSIZE=100
fi

dirstack=()
undodirstack=()

_append_dir_to_dirstack() {
    dir=$1

    if (( ! $dirstack[(Ie)$dir] )); then
        dirstack+=($dir)
    fi

    if (( ${#dirstack[@]} > $DIRSTACKSIZE )); then
        shift dirstack
    fi
}

_append_dir_to_undodirstack() {
    dir=$1

    if (( ! $undodirstack[(Ie)$dir] )); then
        undodirstack+=($dir)
    fi

    if (( ${#undodirstack[@]} > $DIRSTACKSIZE )); then
        shift undodirstack
    fi
}

_append_pwd_to_dirstack() {
    _append_dir_to_dirstack $PWD
}

_go_back() {
    if (( $#dirstack > 1 )); then
        dir_to_go=$dirstack[-2]
        dir_to_go=${dir_to_go/#$HOME/\~}
        RBUFFER="cd $dir_to_go"
        _append_dir_to_undodirstack $dirstack[-1]
        shift -p dirstack
    fi
}

_go_forward() {
    if (( $#undodirstack > 0 )); then
        dir_to_go=$undodirstack[-1]
        dir_to_go=${dir_to_go/#$HOME/\~}
        RBUFFER="cd $dir_to_go"
        _append_dir_to_dirstack $dir_to_go
        shift -p undodirstack
    fi
    zle reset-prompt
}

chpwd_functions+=(_append_pwd_to_dirstack)
_append_pwd_to_dirstack

zle -N _go_back
zle -N _go_forward

bindkey -M vicmd '^O' _go_back
bindkey -M vicmd '^I' _go_forward
