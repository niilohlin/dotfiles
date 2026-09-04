---@diagnostic disable: undefined-global
require("hs.ipc")

-- Track every hotkey created below so we can suspend them all (e.g. while a
-- fullscreen game is running). Wrapping new/bind keeps the rest of the config
-- untouched while still capturing each hotkey object.
local all_hotkeys = {}
local orig_hotkey_new = hs.hotkey.new
hs.hotkey.new = function(...)
  local hk = orig_hotkey_new(...)
  table.insert(all_hotkeys, hk)
  return hk
end
local orig_hotkey_bind = hs.hotkey.bind
hs.hotkey.bind = function(...)
  local hk = orig_hotkey_bind(...)
  table.insert(all_hotkeys, hk)
  return hk
end

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
  hs.eventtap.keyStroke({ "shift" }, "return")
end)
hs.hotkey.new({ "ctrl" }, "m", function()
  hs.eventtap.keyStroke({  }, "return")
end):enable()
hs.hotkey.new({ "ctrl" }, "h", function()
  hs.eventtap.keyStroke({  }, "delete")
end):enable()


ctrl_w_delete_word:enable()
ctrl_u_delete_line:enable()
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

hs.hotkey.bind({"alt"}, "f", function()
  hs.eventtap.keyStroke({"alt"}, "right")
end)

hs.hotkey.bind({"alt"}, "b", function()
  hs.eventtap.keyStroke({"alt"}, "left")
end)

hs.hotkey.bind({ "ctrl" }, "[", function()
  hs.eventtap.keyStroke({}, "escape")
end)

hs.hotkey.bind({ "ctrl" }, "i", function()
  hs.eventtap.keyStroke({}, "tab")
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

-- Suspend all Hammerspoon hotkeys while Age of Empires II is running, so the
-- game receives every keystroke without interference. ------------------------
local AOE_NAME_PATTERNS = { "age of empires", "aoe2", "aoe" }

local function is_aoe(app_name)
  if not app_name then return false end
  local lower = string.lower(app_name)
  for _, pat in ipairs(AOE_NAME_PATTERNS) do
    if string.find(lower, pat, 1, true) then return true end
  end
  return false
end

local hotkeys_suspended = false

local function suspend_hotkeys()
  if hotkeys_suspended then return end
  hotkeys_suspended = true
  for _, hk in ipairs(all_hotkeys) do hk:disable() end
  print("AoE2 detected: Hammerspoon hotkeys suspended")
end

local function resume_hotkeys()
  if not hotkeys_suspended then return end
  hotkeys_suspended = false
  for _, hk in ipairs(all_hotkeys) do hk:enable() end
  print("AoE2 closed: Hammerspoon hotkeys resumed")
end

-- Handle the case where the game is already running when the config loads.
for _, app in ipairs(hs.application.runningApplications()) do
  if is_aoe(app:name()) then
    suspend_hotkeys()
    break
  end
end

AoeWatcher = hs.application.watcher.new(function(app_name, event_type, _app)
  if not is_aoe(app_name) then return end
  if event_type == hs.application.watcher.launched then
    suspend_hotkeys()
  elseif event_type == hs.application.watcher.terminated then
    resume_hotkeys()
  end
end)
AoeWatcher:start()

print("done reloading")

