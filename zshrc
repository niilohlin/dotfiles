#!/bin/zsh

xhost +local:root > /dev/null 2>&1

export HISTSIZE=100000
export HISTFILESIZE=${HISTSIZE}
export SAVEHIST=${HISTSIZE}
export HISTFILE=~/.zsh_hist

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt appendhistory
setopt sharehistory
setopt incappendhistory

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

function copy() {
    cat $1 | pbcopy
}

function gclean() {
    git branch --merged | egrep -v "(^\*|main|dev)" | xargs git branch -d
    git fetch --all --prune
    exec git for-each-ref refs/heads/ "--format=%(refname:short)" | grep -v main | xargs -P 4 -I {} bash -c "( ! git cherry main {} | grep -q '^[^-]' ) && git branch -D {}"
    #git gc
}

function commitsAtDate() {
    git log --pretty='format:%C(yellow)%h %G? %ad%Cred%d %Creset%s%C(cyan) [%cn]' --decorate --after="$1 00:00" --before="$1 23:59" --author "`git config user.name`";
}

zstyle ':completion:*:*' ignored-patterns '*ORIG_HEAD' '*/*'
autoload -Uz compinit && compinit
zstyle ':completion:*' menu yes select
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'

# This block fixes search so that it searches history based on what you started typing
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M viins "^[[A" up-line-or-beginning-search
bindkey -M viins "^[[B" down-line-or-beginning-search

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Automatically ls after cd and add it to a hook
chpwd_functions+=(ls)

set -o vi
set keymap vi-insert

export PATH=$PATH:$HOME/dotfiles/
export PATH=$PATH:/usr/local/bin/
export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/
export PATH=$PATH:/opt/homebrew/opt/postgresql@16/bin


. /opt/homebrew/opt/asdf/libexec/asdf.sh
alias asht asdf

PATH="$PATH:$(/opt/homebrew/bin/brew --prefix)/opt/llvm@12/bin"
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

export LDFLAGS="${LDFLAGS} -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
export LDFLAGS="${LDFLAGS} -L/opt/homebrew/opt/postgresql@16/lib"

export CPPFLAGS="${CPPFLAGS} -I/opt/homebrew/opt/postgresql@16/include"

export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@16/lib/pkgconfig"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"

## psycopg2
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/libpq/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/libpq/include"

export LDFLAGS="${LDFLAGS} -L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/openssl@3/include"

export LDFLAGS="${LDFLAGS} -L/opt/homebrew/Cellar/sdl2/2.26.4/lib/"
export CPPFLAGS="${CPPFLAGS} -I/opt/homebrew/Cellar/sdl2/2.26.4/include/"

export JAVA_HOME=$(/usr/libexec/java_home)

export PATH="/usr/local/opt/icu4c/bin:$PATH"
export PATH="/usr/local/opt/icu4c/sbin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.local/share/nvim/site/pack/pack/paqs/start/paq-nvim/lua:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"

export PYTHON_CONFIGURE_OPTS="--enable-framework"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/opt/bison/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"

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
