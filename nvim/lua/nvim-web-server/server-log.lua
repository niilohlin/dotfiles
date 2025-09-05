local M = {}
function M.debug(object)
  local file = io.open("/tmp/lua_server.log", "a")
  if file then
    for line in vim.inspect(object):gmatch("[^\r\n]+") do
      file:write(line .. "\n")
    end
    file:close()
    return true
  else
    print("Error: Could not open log file ")
    return false
  end
end

return M
