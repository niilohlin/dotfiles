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
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --graph"
alias gs="git status";
alias gd="git diff";
alias gdc="git diff --cached";
alias gc="git commit";
alias ga="git add";
alias gb='git branch'
alias gsummary='grep "^Updating" | sed "s/Updating //" | xargs git log --oneline | grep "Merge pull request" | awk "{print $1;}" | xargs git show -s --format=%B | grep -v -e "^$" | grep -v "Merge pull request"'
alias vim='nvim'
alias editvimconf='nvim ~/.config/nvim/vimrc'
alias vimtags='/usr/local/Cellar/ctags/5.8_1/bin/ctags'
alias tree='broot'
alias less='vim -R' # use vim in readonly mode as a pager

function gclean() {
    git branch --merged | egrep -v "(^\*|main|dev)" | xargs git branch -d
    git fetch --all --prune
    exec git for-each-ref refs/heads/ "--format=%(refname:short)" | grep -v main | xargs -P 4 -I {} bash -c "( ! git cherry main {} | grep -q '^[^-]' ) && git branch -D {}"
    #git gc
}

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

. /opt/homebrew/opt/asdf/libexec/asdf.sh

eval $(/usr/libexec/path_helper -s)

search() {
    find . -iname "$1"
}

# case insensitive.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load the antidote plugin manager
source ~/.zsh/antidote/antidote.zsh
# Load the plugins from the file
antidote load ~/.zsh/zsh-plugins.txt

source ~/.zsh/git-completion.bash
source ~/.zsh/fastlane-completion.zsh
source ~/.zsh/zsh-cdtree/zsh-cdtree.zsh
fpath=(~/.zsh $fpath)
fpath=(~/.zsh/completions $fpath)

# zstyle ':completion:*' menu no # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup # use fzf-tmux-popup instead of fzf

export LANG=C
export LC_ALL=en_US.UTF-8

eval "$(/opt/homebrew/bin/brew shellenv)"

# Dynamic tree navigation
source ~/.config/broot/launcher/bash/br

export PATH=$HOME/.asdf/shims:$PATH

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
export TERM=xterm-256color
if [ -z $TMUX ]; then
    exec tmux
fi
