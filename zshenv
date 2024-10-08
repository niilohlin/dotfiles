
export PATH=$PATH:$HOME/dotfiles/
export PATH=$PATH:/usr/local/bin/
export PATH=$PATH:$HOME/.cargo/bin

# postgresql 16 config
export PATH=$PATH:/opt/homebrew/opt/postgresql@16/bin
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"

export LANG=C
export LC_ALL=en_US.UTF-8
export INPUTRC=~/.inputrc

source ~/dotfiles/.env
