--- @class Frame
--- @field path string
--- @field line integer
--- @field column integer?
--- @field module string?
--- @field lines string

--- @class Traceback
--- @field stack Frame[]
--- @field inner? Traceback
--- @field error? string

local function parse_file(lines, start)
  local line = lines[start]
  if line == nil then
    return nil, start
  end
  local path, lnum, mod = line:match('^  File "(.+)", line (%d+), in (.+)')

  if path == nil or line == nil then
    return nil, start
  end
  local stack_info = {}

  start = start + 1
  line = lines[start]
  local column = 1
  while line:match("^    ") do
    table.insert(stack_info, line)
    local cols = line:match("^    ([~ ]*)%^")
    if cols ~= nil then
      column = #cols
    end

    start = start + 1
    line = lines[start]
  end

  return { path = path, line = tonumber(lnum), column = column, lines = stack_info, module = mod }, start
end

local function parse_traceback(lines, start)
  local line = lines[start]
  if not line:match("^Traceback %(most recent call last%):") then
    return nil, start
  end

  start = start + 1
  local stack = {}
  local file
  file, start = parse_file(lines, start)
  while file ~= nil do
    stack[#stack + 1] = file
    file, start = parse_file(lines, start)
  end
  local error = lines[start]

  local next_two = lines[start + 2]

  local inner = nil
  if next_two ~= nil and next_two:match("^During handling of the above exception, another exception occurred:") then
    inner = parse_traceback(lines, start + 4)
  end

  return { stack = stack, inner = inner, error = error }
end

vim.api.nvim_create_user_command("ReadPythonStacktrace", function(input)
  local pane = "1"
  if input.args ~= nil and input.args ~= "" then
    pane = input.args
  end

  local pane_output = nil
  if input.line1 ~= input.line2 then
    pane_output = table.concat(vim.fn.getline(input.line1, input.line2), "\n")
  else
    -- read the pane value of window: 1, pane 0
    -- -J: join lines, removes soft wraps
    -- -p: output to stdout
    -- -S: start at the beginning of the history
    pane_output = vim.fn.system("tmux capture-pane -pt :" .. pane .. ".0 -p -J -S -")
  end


  local lines = {}
  for l in pane_output:gmatch("([^\n]*)\n?") do
    table.insert(lines, l)
  end
  local tb = nil
  for i = #lines, 1, -1 do
    local line = lines[i]
    local line_above = lines[i - 2]
    if
        line:match("^Traceback %(most recent call last%):")
        and not line_above:match("^During handling of the above exception, another exception occurred:")
    then
      tb = parse_traceback(lines, i)
      break
    end
  end

  local qf_items = {}

  while tb ~= nil and #tb.stack >= 1 do
    table.insert(qf_items, {
      filename = tb.stack[1].path,
      lnum = tb.stack[1].line,
      col = tb.stack[1].col,
      text = tb.error .. " in " .. tb.stack[1].module,
      type = "E",
    })

    for i = 2, #tb.stack do
      local file = tb.stack[i]
      table.insert(qf_items, {
        filename = file.path,
        lnum = file.line,
        col = file.col,
        text = "  in " .. (file.module or "?"),
        type = "",
      })
    end

    tb = tb.inner
  end

  vim.fn.setqflist({}, "r", {
    items = qf_items,
  })
  vim.cmd("copen")
end, { nargs = "*", range = true })
