#!/usr/bin/env bash

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
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# shell tools
brew install bash bash-completion@2 eza tmux diff-so-fancy git git-lfs keychain bitwarden-cli
# neovim and dependencies
brew install neovim fzf rust lua node rustup luarocks ripgrep xz
# applications
brew install slack messenger anki docker-desktop obsidian gifox bitwarden
# keyboard navigation
brew install hammerspoon

mkdir -v ~/.config

# Link config files
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/ghostty ~/.config/ghostty
# Zed keeps a prompts db in ~/.config/zed, so link the files instead of the dir
mkdir -p ~/.config/zed
ln -s ~/dotfiles/zed/settings.json ~/.config/zed/settings.json
ln -s ~/dotfiles/zed/keymap.json ~/.config/zed/keymap.json
ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
ln -s ~/dotfiles/bashrc ~/.bashrc
ln -s ~/dotfiles/bash_profile ~/.bash_profile
ln -s ~/dotfiles/inputrc ~/.inputrc
ln -s ~/dotfiles/gitconfig ~/.gitconfig
mkdir -p ~/.claude
ln -s ~/dotfiles/claude/hooks ~/.claude/hooks
ln -s ~/dotfiles/claude/settings.json ~/.claude/settings.json
ln -s ~/dotfiles/claude/tmux-window-status.sh ~/.claude/tmux-window-status.sh
ln -s ~/dotfiles/claude/herdr-workspace-title.sh ~/.claude/herdr-workspace-title.sh

herdr plugin link ~/dotfiles/herdr/plugins/ghostty-progress

# bash from Homebrew as login shell
grep -qx /opt/homebrew/bin/bash /etc/shells || echo /opt/homebrew/bin/bash | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash

# ble.sh (autosuggestions, syntax highlighting), not packaged in Homebrew
d=$(mktemp -d) && curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf - -C "$d" && bash "$d/ble-nightly/ble.sh" --install ~/.local/share
