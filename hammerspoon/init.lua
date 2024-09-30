---@diagnostic disable: undefined-global

local search_slack = hs.hotkey.new({'cmd', 'shift'}, 'o', function()
  hs.eventtap.keyStroke({'cmd'}, 'k')
end)

local go_back = hs.hotkey.new({'ctrl'}, 'o', function()
  hs.eventtap.keyStroke({'cmd'}, '[')
end)

local go_forward = hs.hotkey.new({'ctrl'}, 'i', function()
  hs.eventtap.keyStroke({'cmd'}, ']')
end)

local function enable_slack_enhancements()
  search_slack:enable()
  go_back:enable()
  go_forward:enable()
end

local function disable_slack_enhancements()
  search_slack:disable()
  go_back:disable()
  go_forward:disable()
end

hs.window.filter.new('Slack')
:subscribe(hs.window.filter.windowFocused, enable_slack_enhancements)
:subscribe(hs.window.filter.windowUnfocused, disable_slack_enhancements)


hs.window.animationDuration = 0

local function moveWindowRight()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end

  local screen = win:screen()
  local frame = win:frame()
  local screenFrame = screen:frame()

  if frame.x == screenFrame.x + (screenFrame.w / 2) and frame.w <= screenFrame.w / 2 then
    local nextScreen = screen:toEast()
    if nextScreen then
      local nextScreenFrame = nextScreen:frame()
      win:setFrame(hs.geometry.rect(nextScreenFrame.x, nextScreenFrame.y, nextScreenFrame.w / 2, nextScreenFrame.h))
    end
  else
    win:setFrame(hs.geometry.rect(screenFrame.x + (screenFrame.w / 2), screenFrame.y, screenFrame.w / 2, screenFrame.h))
  end
end

local function moveWindowLeft()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local frame = win:frame()
  local screenFrame = screen:frame()

  if frame.x == screenFrame.x and frame.w <= screenFrame.w / 2 then
    local nextScreen = screen:toWest()
    if nextScreen then
      local nextScreenFrame = nextScreen:frame()
      win:setFrame(hs.geometry.rect(nextScreenFrame.x + (nextScreenFrame.w / 2), nextScreenFrame.y, nextScreenFrame.w / 2, nextScreenFrame.h))
    end
  else
    win:setFrame(hs.geometry.rect(screenFrame.x, screenFrame.y, screenFrame.w / 2, screenFrame.h))
  end
end

local function maximizeWindow()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local max = screen:frame()
  win:setFrame(hs.geometry.rect(max.x, max.y, max.w, max.h))
end

local function moveWindowTop()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local max = screen:frame()
  win:setFrame(hs.geometry.rect(max.x, max.y, max.w, max.h / 2))
end

local function moveWindowBottom()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local max = screen:frame()
  win:setFrame(hs.geometry.rect(max.x, max.y + (max.h / 2), max.w, max.h / 2))
end

local function reloadConfig()
  hs.reload()
  hs.alert.show("Hammerspoon config reloaded")
end

hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "R", reloadConfig)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "K", moveWindowTop)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "J", moveWindowBottom)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "L", moveWindowRight)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "H", moveWindowLeft)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "return", maximizeWindow)
