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

local ctrl_w_delete_word = hs.hotkey.new({ "ctrl" }, "w", function()
  hs.eventtap.keyStroke({ "alt" }, "delete")
end)
local ctrl_u_delete_line = hs.hotkey.new({ "ctrl" }, "u", function()
  hs.eventtap.keyStroke({ "cmd" }, "delete")
end)
local ctrl_j_shift_enter = hs.hotkey.new({ "ctrl" }, "j", function()
  hs.eventtap.keyStroke({ "ctrl" }, "return")
end)
hs.hotkey.new({ "ctrl" }, "m", function()
  hs.eventtap.keyStroke({  }, "return")
end):enable()
hs.hotkey.new({ "ctrl" }, "h", function()
  hs.eventtap.keyStroke({  }, "delete")
end):enable()


ctrl_w_delete_word:enable()
ctrl_u_delete_line:enable()
ctrl_j_shift_enter:enable()
hs.window.filter
    .new("Ghostty")
    :subscribe(hs.window.filter.windowFocused, function()
    ctrl_w_delete_word:disable()
    ctrl_u_delete_line:disable()
    ctrl_j_shift_enter:disable()
  end)
    :subscribe(hs.window.filter.windowUnfocused, function()
  ctrl_w_delete_word:enable()
  ctrl_u_delete_line:enable()
  ctrl_j_shift_enter:enable()
end)

-- local focus_next_window = hs.hotkey.new({ "ctrl", "shift" }, "`", function()
-- end)

hs.hotkey.bind({ "ctrl" }, "[", function()
  hs.eventtap.keyStroke({}, "escape")
end)

hs.hotkey.bind({ "ctrl" }, "i", function()
  hs.eventtap.keyStroke({}, "tab")
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "left", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus prev")
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "right", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus next")
end)

-- Block the original Enter key
-- hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
--     local keyCode = event:getKeyCode()
--   print("keycode = ", keyCode)
--     if keyCode == 36 then -- 36 is the key code for Enter
--         return true -- Block the original Enter key
--     end
--     return false
-- end):start()
-- hs.hotkey.bind({ }, "escape", function()end)
-- hs.hotkey.bind({ }, "enter", function()end)
-- hs.hotkey.bind({ }, "left", function()end)
-- hs.hotkey.bind({ }, "right", function()end)
-- hs.hotkey.bind({ }, "backspace", function()end)


hs.window.animationDuration = 0

local win = hs.hotkey.modal.new({ "cmd", "ctrl", "alt", "shift" }, 'W', 'window mode')

win:bind('', 'escape', function() win:exit() end)

win:bind('', "o", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen")
  win:exit()
end)

Menubar = hs.menubar.new()
Menubar:setTitle("1")
Menubar:setTooltip("Just a letter")
Menubar:setClickCallback(function() end)
-- Menubar:setMenu({ { title = "1", disabled = true } })
Menubar:setMenu({})

hs.hotkey.bind("cmd", "1", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 1")
  Menubar:setTitle("1")
end)

hs.hotkey.bind("cmd", "2", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 2")
  Menubar:setTitle("2")
end)

hs.hotkey.bind("cmd", "3", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 3")
  Menubar:setTitle("3")
end)

hs.hotkey.bind("cmd", "4", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 4")
  Menubar:setTitle("4")
end)

hs.hotkey.bind("cmd", "5", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 5")
  Menubar:setTitle("5")
end)

hs.hotkey.bind("cmd", "6", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 6")
  Menubar:setTitle("6")
end)

hs.hotkey.bind("cmd", "7", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 7")
  Menubar:setTitle("7")
end)

hs.hotkey.bind("cmd", "8", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 8")
  Menubar:setTitle("7")
end)

hs.hotkey.bind("cmd", "9", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 9")
  Menubar:setTitle("7")
end)

hs.hotkey.bind("cmd", "0", function()
  hs.execute("/opt/homebrew/bin/yabai -m space --focus 0")
  Menubar:setTitle("7")
end)

local send_to = hs.hotkey.modal.new({ "cmd", "ctrl", "alt", "shift" }, 'y', 'yeet to')
send_to:bind('', 'escape', function() send_to:exit() end)

send_to:bind('', "1", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 1")
  send_to:exit()
end)

send_to:bind('', "2", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 2")
  send_to:exit()
end)

send_to:bind('', "3", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 3")
  send_to:exit()
end)

send_to:bind('', "4", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 4")
  send_to:exit()
end)

send_to:bind('', "5", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 5")
  send_to:exit()
end)

send_to:bind('', "6", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 6")
  send_to:exit()
end)

send_to:bind('', "7", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 7")
  send_to:exit()
end)
send_to:bind('', "8", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 8")
  send_to:exit()
end)
send_to:bind('', "9", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 9")
  send_to:exit()
end)
send_to:bind('', "0", function()
  hs.execute("/opt/homebrew/bin/yabai -m window --space 0")
  send_to:exit()
end)

print("done reloading")

