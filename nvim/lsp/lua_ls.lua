local vim_runtime_paths = {
  vim.fn.expand("$VIMRUNTIME/lua"),
  vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
  vim.fn.expand("$VIMRUNTIME/lua/vim"),
}
local rest = vim.api.nvim_list_runtime_paths()
table.move(rest, 1, #rest, #vim_runtime_paths + 1, vim_runtime_paths)

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.jsonc", ".luarc.json" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {},
      workspace = {
        checkThirdParty = false,
        library = vim_runtime_paths,
      },
      completion = {
        callSnippet = "Replace",
      },
    },
  },
}
