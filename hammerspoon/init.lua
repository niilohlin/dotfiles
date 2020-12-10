
searchSlack = hs.hotkey.new({'cmd', 'shift'}, 'o', function()
      hs.eventtap.keyStroke({'cmd'}, 'k')
  end)

hs.window.filter.new('Slack')
    :subscribe(hs.window.filter.windowFocused,function() searchSlack:enable() end)
    :subscribe(hs.window.filter.windowUnfocused,function() searchSlack:disable() end)
