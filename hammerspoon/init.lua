---@diagnostic disable: undefined-global
require("hs.ipc")

local go_to_in_slack = hs.hotkey.new({ "cmd", "shift" }, "o", function()
  hs.eventtap.keyStroke({ "cmd" }, "k")
end)

local search_all_slack = hs.hotkey.new({ "cmd", "shift" }, "f", function()
  hs.eventtap.keyStroke({ "cmd" }, "g")
end)

local go_back = hs.hotkey.new({ "ctrl" }, "o", function()
  hs.eventtap.keyStroke({ "cmd" }, "[")
end)

local go_forward = hs.hotkey.new({ "ctrl" }, "i", function()
  hs.eventtap.keyStroke({ "cmd" }, "]")
end)

local function enable_slack_enhancements()
  go_to_in_slack:enable()
  go_back:enable()
  go_forward:enable()
  search_all_slack:enable()
end

local function disable_slack_enhancements()
  go_to_in_slack:disable()
  go_back:disable()
  go_forward:disable()
  search_all_slack:disable()
end

hs.window.filter
    .new("Slack")
    :subscribe(hs.window.filter.windowFocused, enable_slack_enhancements)
    :subscribe(hs.window.filter.windowUnfocused, disable_slack_enhancements)

-- local focus_next_window = hs.hotkey.new({ "ctrl", "shift" }, "`", function()
-- end)

hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "left", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus prev")
end)

hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "right", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus next")
end)

hs.window.animationDuration = 0

local win = hs.hotkey.modal.new({ "cmd", "ctrl", "alt", "shift" }, 'W', 'window mode')

win:bind('', 'escape', function() win:exit() end)

win:bind('', "H", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --focus west")
  win:exit()
end)

win:bind('', "L", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --focus east")
  win:exit()
end)

win:bind('', "K", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --focus north")
  win:exit()
end)

win:bind('', "J", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --focus south")
  win:exit()
end)

win:bind({'shift'}, "H", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --swap west")
  win:exit()
end)

win:bind({'shift'}, "L", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --swap east")
  win:exit()
end)

win:bind({'shift'}, "K", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --swap north")
  win:exit()
end)

win:bind({'shift'}, "J", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --swap south")
  win:exit()
end)

win:bind('', "t", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --toggle float --grid 4:4:1:1:2:2")
  win:exit()
end)

win:bind('', "e", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --balance")
  win:exit()
end)

win:bind('', "r", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --rotate 270")
  win:exit()
end)

win:bind('', "o", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen")
  win:exit()
end)

local tabs = hs.hotkey.modal.new({ "cmd", "ctrl", "alt", "shift" }, 'N', 'next screen')

Menubar = hs.menubar.new()
Menubar:setTitle("1")
Menubar:setTooltip("Just a letter")
Menubar:setClickCallback(function() end)
-- Menubar:setMenu({ { title = "1", disabled = true } })
Menubar:setMenu({})

tabs:bind('', 'escape', function() tabs:exit() end)

tabs:bind('', "q", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 1")
  Menubar:setTitle("1")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "q", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 1")
  Menubar:setTitle("1")
  tabs:exit()
end)

tabs:bind('', "d", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 2")
  Menubar:setTitle("2")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "d", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 2")
  Menubar:setTitle("2")
  tabs:exit()
end)

tabs:bind('', "r", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 3")
  Menubar:setTitle("3")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "r", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 3")
  Menubar:setTitle("3")
  tabs:exit()
end)

tabs:bind('', "w", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 4")
  Menubar:setTitle("4")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "w", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 4")
  Menubar:setTitle("4")
  tabs:exit()
end)

tabs:bind('', "b", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 5")
  Menubar:setTitle("5")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "b", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 5")
  Menubar:setTitle("5")
  tabs:exit()
end)

tabs:bind('', "a", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 6")
  Menubar:setTitle("6")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "a", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 6")
  Menubar:setTitle("6")
  tabs:exit()
end)

tabs:bind('', "s", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 7")
  Menubar:setTitle("7")
  tabs:exit()
end)

tabs:bind({ "cmd", "ctrl", "alt", "shift" }, "s", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 7")
  Menubar:setTitle("7")
  tabs:exit()
end)

local send_to = hs.hotkey.modal.new({ "cmd", "ctrl", "alt", "shift" }, 'y', 'yeet to')
send_to:bind('', 'escape', function() send_to:exit() end)

send_to:bind('', "q", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 1")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "q", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 1")
  send_to:exit()
end)

send_to:bind('', "d", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 2")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "d", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 2")
  send_to:exit()
end)

send_to:bind('', "r", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 3")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "r", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 3")
  send_to:exit()
end)

send_to:bind('', "w", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 4")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "w", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 4")
  send_to:exit()
end)

send_to:bind('', "b", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 5")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "b", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 5")
  send_to:exit()
end)

send_to:bind('', "a", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 6")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "a", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 6")
  send_to:exit()
end)

send_to:bind('', "s", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 7")
  send_to:exit()
end)

send_to:bind({ "cmd", "ctrl", "alt", "shift" }, "s", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 7")
  send_to:exit()
end)



print("done reloading")

