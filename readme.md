
# Must haves
* brew
* spectacle
* quicksilver
* neovim

to unload macbook keyboard:
```
  sudo kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext
```
to load it again
```
  sudo kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext
```
