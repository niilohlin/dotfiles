# The claude binary honors --use-openssl-ca but not SSL_CERT_FILE, so it ends up trusting nothing
[[ $OSTYPE == darwin* ]] && claude() { env -u NODE_OPTIONS claude "$@"; }

[[ $- == *i* ]] || return

# ble.sh: autosuggestions + syntax highlighting. Attached at the end of this file.
[[ -t 0 && -t 1 && -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --attach=none

HISTSIZE=100000
HISTFILESIZE=$HISTSIZE
HISTFILE=~/.bash_hist
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize globstar

# sort tmp directory by modified date
eza_ls() {
    if [[ $PWD == /tmp ]]; then
        eza --long --sort=modified "${@:-.}"
    else
        eza -G --classify=auto "${@:-.}"
    fi
}

# The `${@:-.}` above matters: given no path, eza reads its file list from stdin
# whenever stdin isn't a tty, so a bare `eza` in a pipe lists nothing.
alias ls='eza_ls'
alias ll='eza -l --group-directories-first --color=auto --classify=auto'
alias la='eza -la --group-directories-first --color=auto --classify=auto'
alias grep='grep --color=tty -d skip'
alias cp="cp -i -r"
alias free='free -m'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --graph"
alias vim='nvim'
alias less='nvim -R'
alias psp='source ~/dotfiles/bin/cd_to_pane_start_path'
alias lg='lazygit'

command -v pyenv >/dev/null && eval "$(pyenv init - bash)"
command -v rbenv >/dev/null && eval "$(rbenv init - --no-rehash bash)"
command -v mise >/dev/null && eval "$(mise activate bash)"

# Load /etc/paths.d/ into the PATH (macOS only)
[[ -x /usr/libexec/path_helper ]] && eval "$(/usr/libexec/path_helper -s)"
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

for f in /opt/homebrew/etc/profile.d/bash_completion.sh /usr/share/bash-completion/bash_completion; do
    [[ -r $f ]] && . "$f" && break
done
command -v aws_completer >/dev/null && complete -C aws_completer aws

# Hit ctrl-r to fzf search history
export FZF_TMUX=1
if [[ ${BLE_VERSION-} ]]; then
    ble-import -d integration/fzf-key-bindings
    ble-import -d integration/fzf-completion
    bleopt history_share=1
else
    eval "$(fzf --bash)"
fi

command -v keychain >/dev/null && eval "$(keychain --eval id_rsa)"

if [[ -z "$TMUX" && -n "$SSH_TTY" ]]; then
  tmux attach-session || tmux new-session
fi

# increase the limit of open files
ulimit -n 8192

# Activate the nearest .venv/venv above $PWD, deactivate when leaving it
_auto_venv() {
    local d=$PWD
    while [[ $d != / && ! -f $d/.venv/bin/activate && ! -f $d/venv/bin/activate ]]; do d=${d%/*}; d=${d:-/}; done
    local venv=$d/.venv; [[ -f $venv/bin/activate ]] || venv=$d/venv
    [[ $VIRTUAL_ENV == "$venv" ]] && return
    [[ -n $VIRTUAL_ENV ]] && type deactivate &>/dev/null && deactivate
    [[ -f $venv/bin/activate ]] && source "$venv/bin/activate"
}

# Runs only at the prompt, like zsh's chpwd_functions: ls after cd, venv autodetect
_prompt_hook() {
    local status=$?
    [[ ${BLE_VERSION-} ]] || { history -a; history -n; }
    if [[ $PWD != "$_last_pwd" ]]; then
        [[ -n $_last_pwd ]] && eza_ls
        _last_pwd=$PWD
        _auto_venv
    fi
    PS1="\n\[\e[34m\]\w\[\e[90m\]$(__git_ps1 ' %s')\[\e[0m\]${VIRTUAL_ENV:+ \[\e[90m\]${VIRTUAL_ENV##*/}\[\e[0m\]}\n"
    (( status )) && PS1+='\[\e[31m\]❯\[\e[0m\] ' || PS1+='\[\e[35m\]❯\[\e[0m\] '
}
VIRTUAL_ENV_DISABLE_PROMPT=1
GIT_PS1_SHOWDIRTYSTATE=1
for f in /opt/homebrew/etc/bash_completion.d/git-prompt.sh /usr/share/git/completion/git-prompt.sh; do
    [[ -r $f ]] && . "$f" && break
done
PROMPT_COMMAND=_prompt_hook

[[ ${BLE_VERSION-} ]] && ble-attach
