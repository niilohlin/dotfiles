if not (vim.fn.exists("g:GuiLoaded") == 1 or vim.fn.exists("g:neovide") == 1 or vim.fn.exists("g:nvy") == 1) then
  return
end

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

-- paste into cmd line
vim.keymap.set("c", "<D-v>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-r>", true, false, true), "c", false)
  vim.api.nvim_feedkeys("*", "c", false)
end)

vim.keymap.set("n", "<c-b>h", function()
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
              print(vim.inspect(entry))
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
              local selection = require("telescope.actions.state").get_selected_entry()
              local result = vim.fn.system("hs -c \"FocusWindowByName('" .. selection.value .. "')\""):gsub("\n", "")
              if result == "false" then
                vim.fn.system("( cd " .. project.all_projects()[selection.value].path .. " && neovide &)")
              end
            end)
            return true
          end,
        })
        :find()
  end

  custom_picker()
end)
