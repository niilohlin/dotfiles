-- Claude code terminal integration
local claude_buf = nil
local claude_win = nil

local function claude_is_visible()
  return claude_win and vim.api.nvim_win_is_valid(claude_win)
end

local function claude_send(text)
  if not claude_buf or not vim.api.nvim_buf_is_valid(claude_buf) then
    return
  end
  local chan = vim.bo[claude_buf].channel
  if chan then
    vim.fn.chansend(chan, text)
  end
end

vim.api.nvim_create_user_command("Claude", function(input)
  local has_args = input.args ~= ""
  local has_range = input.range ~= 0

  if input.bang then
    if claude_is_visible() then
      vim.api.nvim_win_hide(claude_win)
    end
    return
  end

  local file = vim.fn.expand("%:.")
  if claude_is_visible() then
    vim.api.nvim_set_current_win(claude_win)
  elseif claude_buf and vim.api.nvim_buf_is_valid(claude_buf) then
    -- buffer exists but not visible, show it in a new window
    vim.cmd("botright vsplit")
    claude_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(claude_win, claude_buf)
  else
    -- create a new terminal
    vim.cmd("botright vsplit | terminal Claude")
    claude_win = vim.api.nvim_get_current_win()
    claude_buf = vim.api.nvim_get_current_buf()
  end

  if has_range then
    local prefix = file .. ":" .. input.line1 .. "," .. input.line2
    if has_args then
      claude_send(prefix .. " " .. input.args)
    else
      claude_send(prefix .. " ")
    end
  elseif has_args then
    claude_send(input.args)
  end

  vim.cmd("startinsert")
end, { nargs = "*", range = true, bang = true })

