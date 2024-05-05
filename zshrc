#!/bin/zsh

export HISTSIZE=100000
export HISTFILESIZE=${HISTSIZE}
export SAVEHIST=${HISTSIZE}
export HISTFILE=~/.zsh_hist

# Ignore duplicate commands
setopt hist_ignore_all_dups
# Ignore commands that start with a space
setopt hist_ignore_space
# Append history rather than replace it
setopt appendhistory
# Save history after each command
setopt sharehistory
# Save history after each command (should not be combined with sharehistory)
setopt incappendhistory

# sort tmp directory by modified date
function ls() {
    if [[ $PWD == '/tmp' ]]
    then
        eza --long --sort=modified
    else
        eza -G -F
    fi
}

# alias ls='eza -G -F'
alias ll='eza -l --group-directories-first --color=auto -F'
alias la='eza -la --group-directories-first --color=auto -F'
alias grep='grep --color=tty -d skip'
alias cp="cp -i -r"                          # confirm before overwriting something
alias free='free -m'                      # show sizes in MB
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --graph"
alias gs="git status";
alias gd="git diff";
alias gdc="git diff --cached";
alias gc="git commit";
alias ga="git add";
alias gb='git branch'
alias vim='nvim'
alias tree='broot'
alias less='vim -R' # use vim in readonly mode as a pager

# Ignore ORIG_HEAD and anything that looks like a remote branch
zstyle ':completion:*:*' ignored-patterns '*ORIG_HEAD' '*/*'
# Load zsh autocomplete
autoload -Uz compinit && compinit
# Enable menu selection
zstyle ':completion:*' menu yes select
# Highlight the completion in the list, probably not needed since we're using fzf-tab
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'

# This block fixes search so that it searches history based on what you started typing
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M viins "^[[A" up-line-or-beginning-search
bindkey -M viins "^[[B" down-line-or-beginning-search

# Automatically ls after cd and add it to a hook
chpwd_functions+=(ls)

set -o vi
set keymap vi-insert

export PATH=$PATH:$HOME/dotfiles/
export PATH=$PATH:/usr/local/bin/

eval "$(/opt/homebrew/bin/mise activate zsh)"

# Load /etc/paths.d/ into the PATH
eval $(/usr/libexec/path_helper -s)

# case insensitive.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load the antidote plugin manager
source ~/.zsh/antidote/antidote.zsh
# Load the plugins from the file
antidote load ~/.zsh/zsh-plugins.txt

source ~/.zsh/git-completion.bash
source ~/.zsh/fastlane-completion.zsh
fpath=(~/.zsh $fpath)
fpath=(~/.zsh/completions $fpath)

# zstyle ':completion:*' menu no # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup # use fzf-tmux-popup instead of fzf

export LANG=C
export LC_ALL=en_US.UTF-8

eval "$(/opt/homebrew/bin/brew shellenv)"

# Dynamic tree navigation
source ~/.config/broot/launcher/bash/br

# ci", ci', ci`, di", etc
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# ci{, ci(, ci<, di{, etc
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

# Start tmux if not already running
# export TERM=xterm-256color
# if [ -z $TMUX ]; then
#     exec tmux
# fi
