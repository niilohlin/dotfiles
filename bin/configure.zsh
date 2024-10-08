#!/bin/zsh

set -o pipefail

# Configure dock
defaults write com.apple.dock autohide-delay -float 5
defaults write com.apple.dock autohide-time-modifier -int 0
defaults write com.apple.dock pinning -string start
osascript -e "tell application \"System Events\" to set the autohide of the dock preferences to true"
killall Dock

# Natural scroll direction. Not inverted.
defaults write -g com.apple.swipescrolldirection -bool FALSE

# Set default screenshot location
defaults write com.apple.screencapture location /tmp/
