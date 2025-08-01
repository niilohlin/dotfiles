local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")
local null_ls = require("null-ls")
local logger = require("null-ls.logger")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local overrides = {
  severities = {
    error = h.diagnostics.severities["error"],
    warning = h.diagnostics.severities["warning"],
    note = h.diagnostics.severities["information"],
  },
}

return {
  name = "_mypy",
  meta = {
    url = "https://github.com/python/mypy",
    description = [[Mypy is an optional static type checker for Python that aims to combine the...]]
  },
  method = DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_ls.generator({
    dynamic_command = function(params, done)
      -- Detect project root by looking for typical root markers, e.g. .git or pyproject.toml
      local root = vim.fs.normalize(vim.fs.root(params.bufname or params.cwd,
        { "pyproject.toml", "setup.py", "Makefile", "venv", ".git" }))
      or vim.loop.cwd()
      local candidate = root .. "/venv/bin/mypy"
      if vim.fn.executable(candidate) == 1 then
        logger:debug("mypy found in " .. candidate)
        done(candidate)
        return
      end
      vim.notify("mypy not found in " .. root .. ", falling back to global", vim.log.levels.WARN)
      done("mypy")
    end,
    args = function(params)
      return {
        "--hide-error-codes",
        "--hide-error-context",
        "--no-color-output",
        "--show-absolute-path",
        "--show-column-numbers",
        "--show-error-codes",
        "--no-error-summary",
        "--no-pretty",
        "--shadow-file",
        params.bufname,
        params.temp_path,
        params.bufname,
      }
    end,
    to_temp_file = true,
    format = "line",
    check_exit_code = function(code)
      return code <= 2
    end,
    multiple_files = true,
    on_output = h.diagnostics.from_patterns({
      -- see spec for pattern examples
      {
        pattern = "([^:]+):(%d+):(%d+): (%a+): (.*)  %[([%a-]+)%]",
        groups = { "filename", "row", "col", "severity", "message", "code" },
        overrides = overrides,
      },
      -- no error code
      {
        pattern = "([^:]+):(%d+):(%d+): (%a+): (.*)",
        groups = { "filename", "row", "col", "severity", "message" },
        overrides = overrides,
        },
      -- no column or error code
      {
        pattern = "([^:]+):(%d+): (%a+): (.*)",
        groups = { "filename", "row", "severity", "message" },
        overrides = overrides,
      },
    }),
    cwd = h.cache.by_bufnr(function(params)
      return u.root_pattern(
        -- https://mypy.readthedocs.io/en/stable/config_file.html
        "mypy.ini",
        ".mypy.ini",
        "pyproject.toml",
        "setup.cfg",
        "venv",
        "Makefile"
      )(params.bufname)
    end),
  }),
}

