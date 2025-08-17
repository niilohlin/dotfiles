local M = {}

function M.find_autolua_in_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local autolua_blocks = {}
  local current_block = nil
  for row, line in ipairs(lines) do
    if current_block == nil and line:match('^%s*```autolua%s*$') then
      current_block = { row = row, lines = {} }
    elseif current_block ~= nil and line:match('^%s*```%s*$') then
      table.insert(autolua_blocks, current_block)
      current_block = nil
    elseif current_block ~= nil then
      table.insert(current_block.lines, line)
    end
  end
  return autolua_blocks
end

function M.render_task(task)
  local result = ""
  if task.done then
    result = result .. "- [x] "
  else
    result = result .. "- [ ] "
  end
  result = result .. task.name .. " " .. task.due
  return result
end

function M.execute_autolua_in_buffer()
  local autolua_blocks = M.find_autolua_in_buffer()

  for _, block in ipairs(autolua_blocks) do
    local lua_code = table.concat(block.lines, "\n")
    local chunk, error = loadstring(lua_code)
    if chunk then
      local success, result = pcall(chunk)

      local buf = vim.api.nvim_create_buf(false, true)

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)

      vim.api.nvim_open_win(buf, true, {
        relative = 'win',
        width = 80,
        height = 20,
        bufpos = {block.row - 1, 1},
        style = 'minimal',
        border = 'none'
      })

    else
      print("Syntax error:", error)
    end
  end
end


vim.api.nvim_create_user_command('AutoluaFind', function() print(vim.inspect(M.find_autolua_in_buffer())) end, { })

vim.api.nvim_create_user_command('AutoluaExecute', M.execute_autolua_in_buffer, { })

return M
