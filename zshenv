
export PATH=/opt/homebrew/bin/:$PATH
export PATH=/opt/homebrew/opt/node@22/bin:$PATH
export PATH=/opt/homebrew/opt/llvm/bin:$PATH
export PATH="/Users/niilohlin/.local/bin:$PATH"
export PATH=$PATH:$HOME/dotfiles/bin/
export PATH=$PATH:/usr/local/bin/
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.pyenv/bin
export PATH=$PATH:$HOME/.rbenv/shims/
export PATH=$PATH:$HOME/.config/composer/vendor/bin


export NVIM_BIN=/opt/homebrew/bin/nvim

export PYTHONDONTWRITEBYTECODE=1

# postgresql 16 config
export PATH=$PATH:/opt/homebrew/opt/postgresql@16/bin
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include -I/opt/homebrew/opt/llvm/include"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib -L/opt/homebrew/opt/llvm/lib"
export CARGO_HOME=$HOME/.cargo/

export LANG=C
export CC=clang
export LC_ALL=en_US.UTF-8
export INPUTRC=~/.inputrc
export EDITOR=nvim

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@22/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@22/include"


# if [ "$SSH_AUTH_SOCK" = "" -a -x /usr/bin/ssh-agent ]; then
#     eval `/usr/bin/ssh-agent`
# fi
# export SSH_AUTH_SOCK=$(tmux show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)
#

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

export NVM_DIR="$HOME/.nvm"

source ~/dotfiles/.env
. "$HOME/.cargo/env"
