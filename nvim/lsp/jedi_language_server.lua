---@type vim.lsp.Config
return {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" },
  init_options = {
    completion = {
      -- LSP snippets turned out to insisting on inserting parens everywhere
      disableSnippets = true,
    },
  },
}
