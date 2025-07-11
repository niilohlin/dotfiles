#!/bin/zsh

set -o pipefail

# Configure dock
defaults write com.apple.dock autohide-delay -float 1
defaults write com.apple.dock autohide-time-modifier -int 0
defaults write com.apple.dock pinning -string start
osascript -e "tell application \"System Events\" to set the autohide of the dock preferences to true"
killall Dock

# Natural scroll direction. Not inverted.
defaults write -g com.apple.swipescrolldirection -bool FALSE

# Set default screenshot location
defaults write com.apple.screencapture location /tmp/

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# shell tools
brew install eza tmux diff-so-fancy git git-lfs keychain
# neovim and dependencies
brew install neovim fzf rust lua node rustup luarocks ripgrep xz
# applications
brew install slack messenger anki docker-desktop obsidian gifox
# keyboard navigation
brew install rectangle hammerspoon

mkdir -v ~/dotfiles/.config

# Link config files
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/ghostty ~/.config/ghostty
ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
ln -s ~/dotfiles/zsh ~/.zsh
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/zshenv ~/.zshenv
ln -s ~/dotfiles/gitconfig ~/.gitconfig

# install antidote zsh package manager
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.zsh/.antidote
