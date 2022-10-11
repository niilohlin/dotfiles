#!/bin/zsh

set -o pipefail

# Configure dock
defaults write com.apple.dock autohide-delay -float 5; defaults write com.apple.dock autohide-time-modifier -int 0;killall Dock
# Drag windows with cmd+ctrl+mouse
defaults write -g NSWindowShouldDragOnGesture -bool true
# Natural scroll direction. Not inverted.
defaults write -g com.apple.swipescrolldirection -bool FALSE

# Show compile times in Xcode
defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

# link config files

ln -s $HOME/dotfiles/ideavimrc $HOME/.ideavimrc

if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

binstall() {
    if ! command -v $1 &> /dev/null
    then
        echo "Installing $1"
        brew install $1
    else
        echo "Upgrading $1"
        brew upgrade $1
    fi
}

binstall pyenv
binstall rbenv

latest_ruby_version=$(rbenv install -l | grep -E '^\d+\.\d+\.\d+$' | tail -n 1)
rbenv install "$latest_ruby_version"

# install latest stable xcode version
latest_version=$(xcversion list | grep -E "^\d+(\.\d+(\.\d+)?)?( \(installed\))?$" | tail -n 1)

if [[ $latest_version =~ ".*\(installed\)$" ]]
then
    echo "latest already installed"
else
    echo "installing latest xcode version: $latest_version"
    echo "enter username:"
    read username

    echo $username | xcversion install "$latest_version"
fi

binstall jq
# Might have to remove the /usr/local/opt/zlib dir before this works.
binstall zlib

# install command line tools
xcode-select --install

latest_python_version=$(pyenv install -l | grep -E '\s+\d+\.\d+\.\d+' | tail -n 1)

# Install latest python via pyenv
# Python requires zlib
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export CPATH=$(xcrun --show-sdk-path)"/usr/include"

echo "installing python version $latest_python_version"

echo "$latest_python_version" | xargs pyenv install
echo "$latest_python_version" | xargs pyenv version
echo "$latest_python_version" | xargs pyenv global

# neovim setup.
binstall neovim
pip install --upgrade pip
pip install neovim
pip install bpython
binstall cmake

