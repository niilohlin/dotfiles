local qf_namespace = vim.api.nvim_create_namespace("qflist_diagnostics")
local qf_group = vim.api.nvim_create_augroup("qf_group", { clear = true })

local function qflist_to_diagnostics()
  local qflist = vim.fn.getqflist()
  local diagnostics_by_buf = {}

  for _, item in ipairs(qflist) do
    if item.bufnr ~= 0 and item.lnum ~= 0 then
      local bufnr = item.bufnr
      diagnostics_by_buf[bufnr] = diagnostics_by_buf[bufnr] or {}

      local severity_map = {
        E = vim.diagnostic.severity.ERROR,
        W = vim.diagnostic.severity.WARN,
        I = vim.diagnostic.severity.INFO,
        N = vim.diagnostic.severity.HINT,
      }

      table.insert(diagnostics_by_buf[bufnr], {
        lnum = item.lnum - 1,
        col = (item.col or 1) - 1,
        message = item.text or "",
        severity = severity_map[item.type] or vim.diagnostic.severity.ERROR,
        source = "quickfix",
      })
    end
  end

  -- Clear existing diagnostics in this namespace
  vim.diagnostic.reset(qf_namespace)

  -- Set diagnostics per buffer
  for bufnr, diagnostics in pairs(diagnostics_by_buf) do
    vim.diagnostic.set(qf_namespace, bufnr, diagnostics, {})
  end
end

-- Setup autocommand to refresh diagnostics when quickfix list changes
vim.api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
  group = qf_group,
  pattern = { "[^l]*" }, -- ignore location list commands
  callback = qflist_to_diagnostics,
})

vim.api.nvim_create_user_command("QFListDiagnostics", qflist_to_diagnostics, {})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("format", { clear = true }),
  callback = function(ev)
    local makefile = vim.fn.findfile("Makefile.private", ".;") or ""
    if makefile == "" then
      return
    end

    local ext = vim.fn.fnamemodify(ev.file, ":e")
    local allowed_filetypes = nil

    -- Read the first "# filetypes:" line
    for line in io.lines(makefile) do
      local ft_line = line:match("^#%s*filetypes%s*:%s*(.*)")
      if ft_line then
        allowed_filetypes = {}
        for ft in ft_line:gmatch("%S+") do
          allowed_filetypes[ft:gsub("^%.", "")] = true -- remove leading dot if present
        end
        break
      end
    end

    if allowed_filetypes and not allowed_filetypes[ext] then
      return
    end

    local has_format = false
    for line in io.lines(makefile) do
      if line:match("^format:") then
        has_format = true
        break
      end
    end

    if has_format then
      vim.cmd("Make -f Makefile.private format FILE=" .. ev.file)
    end

    local has_lint = false
    for line in io.lines(makefile) do
      if line:match("^lint:") then
        has_lint = true
        break
      end
    end

    if has_lint then
      vim.cmd("Make -f Makefile.private lint FILE=" .. ev.file)
    end
  end,
})


vim.keymap.set("n", "<leader>tr", function()
  local bufnr = 0
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("No file name for current buffer.", vim.log.levels.WARN)
    return
  end

  local function extract_testname(line)
    -- matches: def test_something(...):
    return line:match("^%s*def%s+(test[%w_]+)%s*%(")
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
  local testname = extract_testname(line)

  if not testname then
    local max_up = 100
    local top = math.max(1, row - max_up)
    for r = row - 1, top, -1 do
      local l = vim.api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1] or ""
      local name = extract_testname(l)
      if name then
        testname = name
        break
      end
    end
  end

  if not testname then
    testname = "test_"
  end

  local relfile = vim.fn.fnamemodify(file, ":.")

  local makefile = vim.fn.findfile("Makefile.private", ".;") or ""
  if makefile == "" then
    vim.notify("no makefile found", vim.log.levels.WARN)
    return
  end

  local has_test = false
  for line in io.lines(makefile) do
    if line:match("^test:") then
      has_test = true
      break
    end
  end

  if has_test then
    vim.cmd("Make -f Makefile.private test TEST=" .. testname .. " FILE=" .. relfile)
  else
    vim.notify("no test: found", vim.log.levels.WARN)
  end

end, { desc = "Run nearest pytest (current or up to 100 lines above)" })
