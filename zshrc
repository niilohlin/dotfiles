#!/bin/zsh

# if [ -z $TMUX ]; then
#     exec tmux
# fi

xhost +local:root > /dev/null 2>&1

export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
export SAVEHIST=${HISTSIZE}
export HISTFILE=~/.zsh_hist

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt appendhistory
setopt sharehistory
setopt incappendhistory


export HD='/run/media/niil/8d25eb81-c066-48cd-a263-83d2b0b3308c/'

function ls() {
    if [[ $PWD == '/tmp' ]]
    then
        exa --long --sort=modified
    else
        exa -G -F
    fi
}

# alias ls='exa -G -F'
alias ll='exa -l --group-directories-first --color=auto -F'
alias la='exa -la --group-directories-first --color=auto -F'
alias grep='grep --color=tty -d skip'
alias cp="cp -i -r"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias carup='carthage update --platform iOS --cache-builds'
alias carbs='carthage bootstrap --platform iOS --cache-builds'
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
alias cd..='cd ..'

function copy() {
    cat $1 | pbcopy
}

function asht() {
    cat $1 | pbcopy
}

function gclean() {
    git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
    git fetch --all --prune
    exec git for-each-ref refs/heads/ "--format=%(refname:short)" | grep -v master | xargs -P 4 -I {} bash -c "( ! git cherry develop {} | grep -q '^[^-]' ) && git branch -D {}"
    #git gc
}

function commitsAtDate() {
    git log --pretty='format:%C(yellow)%h %G? %ad%Cred%d %Creset%s%C(cyan) [%cn]' --decorate --after="$1 00:00" --before="$1 23:59" --author "`git config user.name`";
}

zstyle ':completion:*:*' ignored-patterns '*ORIG_HEAD' '*/*'
autoload -Uz compinit && compinit
zstyle ':completion:*' menu yes select
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'

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

function cdAndLs {
	\cd $1;
	ls # --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F;
}
function mkdirAndCd {
	\mkdir $1;
	cd $1 # --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F;
}
function cdr {
    cd $1
    NUMBER_OF_SUBDIRS=$(ls -d */ | wc -l)
    if [ "$NUMBER_OF_SUBDIRS" -eq "1" ]
    then
        cdr $(ls)
    fi
}

function clock {
	tty-clock -bcC 4
}

alias cd='cdAndLs'
alias mkdir='mkdirAndCd'
alias lynx='lynx --accept_all_cookies'
alias last_touched_file='ls -t *.crash | head -1 t branch --merged | egrep -v "(^\*|master|dev)"'

set -o vi
bindkey -M viins 'tn' vi-cmd-mode
bindkey -a -s _ 0wi
set keymap vi-insert
# bind -m vi-instert "\C-l":clear-screen

# prompt
autoload -U colors && colors
function get_pwd() {
    pwd | sed "s|$HOME|~|"
}
#PROMPT="$fg[cyan]%m: $fg[yellow]$(get_pwd)
#-> "
PS1="%{%F{red}%}%n%{%f%}@%{%F{blue}%}%m %{%F{yellow}%}%~ %{$%f%}% "


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH=$PATH:$HOME/bin/
PATH=$PATH:$HOME/.cabal/bin/
PATH=$PATH:$HOME/.fastlane/bin
PATH=$PATH:/usr/local/Cellar
PATH=$PATH:/usr/local/bin/
PATH=$PATH:/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/
PATH=$PATH:$HOME/dotfiles/
PATH=/usr/local/opt/sqlite/bin:$PATH
#PATH=/usr/local/lib/ruby/gems/2.5.0/bin:$PATH
eval $(/usr/libexec/path_helper -s)

search() {
    find ./ -iname "$1"
}

[ -s "/Users/niilohlin/.k/kvm/kvm.sh" ] && . "/Users/niilohlin/.k/kvm/kvm.sh" # Load kvm

# case insensitive.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

source ~/.zsh/git-completion.bash
source ~/.zsh/fastlane-completion.zsh
fpath=(~/.zsh $fpath)
fpath=(~/.zsh/completions $fpath)
# fpath+=~/.zsh/pure

source ~/.zsh/pure/async.zsh
source ~/.zsh/pure/pure.zsh

export LANG=C
export LC_ALL=en_US.UTF-8

export LDFLAGS="${LDFLAGS} -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/zlib/include"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/openjdk/include"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"
export GROOVY_HOME=/usr/local/opt/groovy/libexec

## psycopg2
export LDFLAGS="-L/usr/local/opt/libpq/lib"
export CPPFLAGS="-I/usr/local/opt/libpq/include"
# export LDFLAGS="-I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib" pip install psycopg2
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"

export NOTES_DIR="$HOME"/Documents/notes
function new_note() {
    if [ -z $1 ]
    then
        ID="$(date +%FT%T).md"
    else
        ID="$(date +%FT%T)-$1.md"
    fi
    vim $NOTES_DIR/$ID
}

#eval $(thefuck --alias)

#reattach-to-user-namespace -l ${SHELL}
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/usr/local/opt/icu4c/bin:$PATH"
export PATH="/usr/local/opt/icu4c/sbin:$PATH"
export PATH="$HOME/.pyenv/shims:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.local/share/nvim/site/pack/pack/paqs/start/paq-nvim/lua:$PATH"

eval "$(rbenv init -)"

export PYTHON_CONFIGURE_OPTS="--enable-framework"
eval "$(pyenv init -)"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

PATH="/Users/niilohlin/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/niilohlin/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/niilohlin/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/niilohlin/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/niilohlin/perl5"; export PERL_MM_OPT;
export PATH="/usr/local/opt/bison/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"

#source /Users/niilohlin/.config/broot/launcher/bash/br
