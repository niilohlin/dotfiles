local function set_tab_length(tab_length)
  vim.opt.tabstop = tab_length
  vim.opt.shiftwidth = tab_length
  vim.opt.softtabstop = tab_length
  vim.opt.expandtab = true
end

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "*.js", "*.jsx", "typescript", "*.ts", "*.tsx" },
  callback = function()
    set_tab_length(2)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    set_tab_length(2)
  end
})

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


vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "swift",
  callback = function()
    vim.cmd([[ call clearmatches() ]])
    vim.cmd([[ call matchadd('ColorColumn', '\%121v', 100) ]])
    vim.cmd([[ setlocal textwidth=120 ]])
  end,
}
)

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.stencil",
  command = "set filetype=swift",
}
)

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "yaml",
  callback = function()
    set_tab_length(2)
  end,
}
)

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "Fastfile", "Appfile", "Snapfile", "Scanfile", "Gymfile", "Matchfile", "Deliverfile", "Dangerfile", "*.gemspec" },
  callback = function()
    vim.cmd([[ set ft=ruby ]])
    vim.cmd([[compiler ruby]])

    set_tab_length(2)
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile" }, {
  pattern = "*.rb",
  command = "0r ~/.config/nvim/skeleton/skeleton.rb",
})


vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.log", "*.logs", "*.out", "output" },
  callback = function()
    vim.cmd([[ set ft=log ]])

    local output_file = os.getenv("NVIM_OUTPUT_FILE")
    if output_file then
      vim.keymap.set('v', '<leader>v', function()
        vim.cmd("normal! \"vy")
        local selected_text = vim.fn.getreg("v")
        local file = io.open(output_file, "a")
        if file == nil then
          print("Could not open file: " .. output_file)
          return
        end
        file:write(selected_text)
        file:close()
        vim.cmd("q")
      end)
    end
  end,
})

vim.api.nvim_create_autocmd({ "CursorHold" }, {
  callback = function()
    -- check if the current buffer is a terminal
    if vim.fn.getbufvar(vim.fn.bufnr("%"), "&buftype") ~= 'nofile' then
      vim.api.nvim_command("checktime")
    end
  end,
})
