
# Must haves
* brew
* spectacle
* neovim


To install the keyboard layouts:

```
  sudo cp -r Keyboard\ Layouts/* /Library/Keyboard\ Layouts/
```

Remember to change scroll direction and to switch cmd and option keys on keyboard.

to unload macbook keyboard:
```
  sudo kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext
```
to load it again
```
  sudo kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext
```
