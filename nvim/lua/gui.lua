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

vim.keymap.set({ "t" }, "<D-v>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-\\><c-n>", true, false, true), "*", false)
  vim.api.nvim_feedkeys('"+pa', "*", false)
end)

vim.keymap.set("c", "<D-v>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-r>", true, false, true), "c", false)
  vim.api.nvim_feedkeys("*", "c", false)
end)

-- speedup neovide animation
vim.g.neovide_position_animation_length = 0.05
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
-- vim.g.neovide_scroll_animation_far_lines = 0
vim.g.neovide_scroll_animation_length = 0.1

local last_project_path = vim.fn.stdpath("data") .. "/last_project"
vim.keymap.set({ "n", "t" }, "<c-b>h", function()
  local project = require("project")

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local project_names = {}
  for name, _ in pairs(project.all_projects()) do
    table.insert(project_names, name)
  end

  local custom_picker = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
          prompt_title = "Workspaces",
          finder = finders.new_table({
            results = project_names,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry,
                ordinal = entry,
              }
            end,
          }),
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)

              vim.fn.writefile({ vim.o.titlestring }, last_project_path)

              local selection = require("telescope.actions.state").get_selected_entry()
              local result = vim.fn.system("hs -c \"FocusWindowByName('" .. selection.value .. "')\""):gsub("\n", "")
              if result == "false" then
                local random_port = math.random(10000, 20000)
                vim.fn.system(
                  " ( cd " .. project.all_projects()[selection.value].path .. " && neovide & )"
                -- "( cd "
                -- .. project.all_projects()[selection.value].path
                -- .. " && nvim --headless --listen localhost:"
                -- .. random_port
                -- .. " &; neovide --server=localhost:"
                -- .. random_port
                -- .. " )"
                )
              end
            end)
            return true
          end,
        })
        :find()
  end

  custom_picker()
end)

vim.keymap.set({ "n", "t" }, "<c-b>L", function()
  if vim.fn.filereadable(last_project_path) then
    local selection = vim.fn.readfile(last_project_path)[1]
    vim.fn.writefile({ vim.o.titlestring }, last_project_path)
    vim.fn.system("hs -c \"FocusWindowByName('" .. selection .. "')\""):gsub("\n", "")
  end
end)

vim.keymap.set({ "n", "t" }, "<c-b>c", function()
  vim.cmd("tabnew | terminal")
end)

vim.keymap.set({ "n", "t" }, "<c-b>n", function()
  vim.cmd("tabnext")
end)

vim.keymap.set({ "n", "t" }, "<c-b>p", function()
  vim.cmd("tabprev")
end)

vim.keymap.set("t", "<c-b>[", function()
  -- go to normal mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-\\><c-n>", true, false, true), "n", false)
end)

vim.keymap.set({ "n", "t" }, '<c-b>"', function()
  vim.cmd("split | terminal")
end)

vim.keymap.set({ "n", "t" }, "<c-b>0", function()
  vim.cmd("tabn 1")
end)

vim.keymap.set({ "n", "t" }, "<c-b>1", function()
  vim.cmd("tabn 2")
end)

vim.keymap.set({ "n", "t" }, "<c-b>3", function()
  vim.cmd("tabn 4")
end)

vim.keymap.set({ "n", "t" }, "<c-b>4", function()
  vim.cmd("tabn 5")
end)
