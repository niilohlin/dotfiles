-- Claude code terminal integration
local claude_pane_id = nil
-- panes picked with :ClaudeConnectPane are trusted even if they are not running claude
local claude_pane_manual = false

local function all_pane_commands()
  local commands = {}
  for line in vim.fn.system("tmux list-panes -a -F '#{pane_id} #{pane_current_command}'"):gmatch("[^\n]+") do
    local id, command = line:match("^(%%%d+)%s*(.*)$")
    if id then
      commands[id] = command
    end
  end
  return commands
end

local function is_claude(command)
  return command ~= nil and command:match("claude") ~= nil
end

local function claude_panes()
  local target = vim.env.TMUX_PANE or ""
  local cmd = "tmux list-panes -F '#{pane_index} #{pane_id} #{pane_current_command}'"
  if target ~= "" then
    cmd = cmd .. " -t " .. vim.fn.shellescape(target)
  end
  local panes = {}
  for line in vim.fn.system(cmd):gmatch("[^\n]+") do
    local index, id, command = line:match("^(%d+)%s+(%%%d+)%s*(.*)$")
    if index then
      table.insert(panes, { index = index, id = id, command = command })
    end
  end
  return panes
end

-- Reuses the connected pane, otherwise adopts a claude pane already open in this
-- tmux window. Returns nil when neither exists.
local function resolve_claude_pane()
  local commands = all_pane_commands()

  if claude_pane_id and commands[claude_pane_id] then
    if claude_pane_manual or is_claude(commands[claude_pane_id]) then
      return claude_pane_id
    end
  end

  claude_pane_id = nil
  claude_pane_manual = false

  for _, pane in ipairs(claude_panes()) do
    if pane.id ~= vim.env.TMUX_PANE and is_claude(pane.command) then
      claude_pane_id = pane.id
      return claude_pane_id
    end
  end

  return nil
end

local function claude_send(text)
  if not claude_pane_id then
    return
  end
  vim.fn.system("tmux send-keys -t " .. vim.fn.shellescape(claude_pane_id) .. " -l " .. vim.fn.shellescape(text))
end

vim.api.nvim_create_user_command("Claude", function(input)
  local has_args = input.args ~= ""
  local has_range = input.range ~= 0

  local file = vim.fn.expand("%:.")
  if resolve_claude_pane() then
    vim.fn.system("tmux select-pane -t " .. vim.fn.shellescape(claude_pane_id))
  else
    local result = vim.fn.system("tmux split-window -h -P -F '#{pane_id}' 'claude'")
    claude_pane_id = result:gsub("%s+$", "")
    claude_pane_manual = false
  end

  if input.bang then
    local lines
    if has_range then
      lines = vim.api.nvim_buf_get_lines(0, input.line1 - 1, input.line2, false)
    else
      lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    end
    claude_send(table.concat(lines, "\n"))
    return
  end

  if has_range then
    local prefix
    if input.line1 == 0 then
      prefix = file
    else
      prefix = file .. ":" .. input.line1 .. "," .. input.line2
    end
    if has_args then
      claude_send(prefix .. " " .. input.args)
    else
      claude_send(prefix .. " ")
    end
  elseif has_args then
    claude_send(input.args)
  end
end, { nargs = "*", range = true, bang = true })

vim.api.nvim_create_user_command("ClaudeConnectPane", function(input)
  local panes = claude_panes()

  if input.args == "" then
    resolve_claude_pane()
    local lines = {}
    for _, pane in ipairs(panes) do
      local marker = pane.id == claude_pane_id and " <- connected" or ""
      table.insert(lines, pane.index .. ": " .. pane.id .. " " .. pane.command .. marker)
    end
    if #lines == 0 then
      vim.notify("No tmux panes found", vim.log.levels.ERROR)
    else
      vim.notify(table.concat(lines, "\n"))
    end
    return
  end

  for _, pane in ipairs(panes) do
    if pane.index == input.args or pane.id == input.args then
      claude_pane_id = pane.id
      claude_pane_manual = true
      vim.notify("Claude connected to pane " .. pane.index .. " (" .. pane.id .. ")")
      return
    end
  end

  vim.notify("No tmux pane " .. input.args .. " in this window", vim.log.levels.ERROR)
end, {
  nargs = "?",
  complete = function()
    local indexes = {}
    for _, pane in ipairs(claude_panes()) do
      table.insert(indexes, pane.index)
    end
    return indexes
  end,
})
