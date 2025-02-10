
if not (vim.fn.exists('g:GuiLoaded') == 1 or vim.fn.exists('g:neovide') == 1 or vim.fn.exists('g:nvy') == 1) then
  return
end

-- set mouse
vim.opt.mouse = "a"

vim.keymap.set("n", "<D-s>", function()
  vim.cmd("w")
end)

vim.keymap.set("n", "<D-z>", function()
  vim.cmd("undo")
end)



