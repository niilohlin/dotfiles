vim.cmd("set title")

vim.keymap.set("n", "<D-s>", function()
  vim.cmd("w")
end)

vim.keymap.set("n", "<D-z>", function()
  vim.cmd("undo")
end)

vim.keymap.set({ "n", "i" }, "<D-v>", function()
  vim.cmd('normal "+p')
end)

vim.keymap.set("v", "<D-c>", function()
  vim.cmd('normal "+y')
end)

vim.keymap.set({ "n", "v" }, "<D-+>", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
end)
vim.keymap.set({ "n", "v" }, "<D-->", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
end)

vim.keymap.set({ "t" }, "<D-v>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-\\><c-n>", true, false, true), "*", false)
  vim.api.nvim_feedkeys('"+pa', "*", false)
end)

vim.keymap.set("c", "<D-v>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-r>", true, false, true), "c", false)
  vim.api.nvim_feedkeys("*", "c", false)
end)

-- speedup neovide animation
vim.g.neovide_position_animation_length = 0
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_scroll_animation_far_lines = 1
vim.g.neovide_scroll_animation_length = 0.03
