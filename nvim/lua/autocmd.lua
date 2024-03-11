
vim.api.nvim_create_autocmd(
    "FileType",
    { pattern = "javascript", command = "setlocal tabstop=2 shiftwidth=2" }
)
vim.api.nvim_create_autocmd(
    "FileType",
    { pattern = "typescript", command = "setlocal tabstop=2 shiftwidth=2" }
)
