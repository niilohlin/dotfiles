local pwd = vim.loop.cwd()
vim.env.RUST_BACKTRACE = 1
return {
  name = "SithLSP",
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" },
  cmd = { "/Users/niilohlin/personal/sith-language-server/target/debug/sith-lsp" },
  init_options = {
    settings = {
      logLevel = "debug",
      logFile = "/tmp/sith.log",
      ruff = {
        lint = {
          enable = false,
        },
      },
    },
  },
}
