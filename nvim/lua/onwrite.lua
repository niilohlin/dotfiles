
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

