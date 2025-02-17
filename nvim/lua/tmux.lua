local M = {}

---@param name string
---@param setup function|nil
function M.ensure_window(name, setup)
  local window_names = vim.split(vim.fn.system('tmux list-windows -F "#{window_name}"'), "\n")
  for _, window_name in ipairs(window_names) do
    if window_name == name then
      return
    end
  end
  vim.fn.system("tmux new-window -n " .. name)
  if setup ~= nil then
    setup()
  end
end

return M
