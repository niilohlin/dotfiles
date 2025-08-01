local null_ls = require("null-ls")
local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS
local logger = require("null-ls.logger")

return h.make_builtin({
  name = "_pylint",
  meta = {
    url = "https://github.com/PyCQA/pylint",
    description = [[Pylint ]],
  },
  method = DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_ls.generator({
    dynamic_command = function(params, done)
      -- Detect project root by looking for typical root markers, e.g. .git or pyproject.toml
      local root = vim.fs.normalize(vim.fs.root(params.bufname or params.cwd,
        { "pyproject.toml", "setup.py", "Makefile", "venv", ".git" }))
      or vim.loop.cwd()
      local candidate = root .. "/venv/bin/pylint"
      if vim.fn.executable(candidate) == 1 then
        done(candidate)
        logger:debug("pylint found in " .. candidate)
        return
      end
      vim.notify("pylint not found in " .. root .. ", falling back to global", vim.log.levels.WARN)
      done("pylint")
    end,
    to_stdin = true,
    args = { "--from-stdin", "$FILENAME", "-f", "json" },
    format = "json",
    check_exit_code = function(code)
      return code ~= 32
    end,
    on_output = h.diagnostics.from_json({
      attributes = {
        row = "line",
        col = "column",
        code = "symbol",
        severity = "type",
        message = "message",
        message_id = "message-id",
        symbol = "symbol",
        source = "pylint",
      },
      severities = {
        convention = h.diagnostics.severities["information"],
        refactor = h.diagnostics.severities["information"],
      },
      offsets = {
        col = 1,
        end_col = 1,
      },
    }),
    cwd = h.cache.by_bufnr(function(params)
      return u.root_pattern(
        -- https://pylint.readthedocs.io/en/latest/user_guide/usage/run.html#command-line-options
        "pylintrc",
        ".pylintrc",
        "pyproject.toml",
        "setup.cfg",
        "tox.ini"
      )(params.bufname)
    end),
  }),
})
