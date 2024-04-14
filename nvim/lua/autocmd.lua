
-- Set cursor position to old spot
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  callback = function()
    vim.cmd([[ if line("'\"") > 1 && line("'\"") <= line("$") | exe  "normal! g'\"" | endif ]])
  end,
})

-- Remove blank space, and put the cursor back where it was
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    vim.cmd([[ normal mi ]])
    vim.cmd([[ :%s/\s\+$//e ]])
    vim.cmd([[ normal 'i ]])
  end,
})

vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = "javascript", command = "setlocal tabstop=2 shiftwidth=2" }
)
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = "typescript", command = "setlocal tabstop=2 shiftwidth=2" }
)
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = "lua", command = "setlocal tabstop=2 shiftwidth=2" }
)
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = "markdown", command = "set spell nofoldenable" }
)

-- Make Vim tmux runner compatible with python
vim.api.nvim_create_autocmd(
  "FileType",
  {
    pattern = "python",
    callback = function()
      vim.cmd([[ let g:VtrStripLeadingWhitespace = 0 ]])
      vim.cmd([[ let g:VtrClearEmptyLines = 0 ]])
      vim.cmd([[ let g:VtrAppendNewline = 1 ]])
    end,
  }
)

vim.api.nvim_create_autocmd({ "BufNewFile" }, {
  pattern = "*.py",
  command = "0r ~/.config/nvim/skeleton/skeleton.py"
})
