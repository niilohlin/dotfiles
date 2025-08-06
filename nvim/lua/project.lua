-- tmux sessionizer like search but in vim
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values

-- helper: list subdirs of a given directory
local function get_subdirs(dir)
  local subdirs = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then return subdirs end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if type == "directory" then
      table.insert(subdirs, {
        path = dir .. name,
        name = name,
      })
    end
  end
  return subdirs
end

function _G.project_picker()
  -- parent project dirs
  local base_dirs = {
    { path = vim.fn.expand('~/dotfiles/'), name = 'dotfiles' },
    { path = vim.fn.expand('~/work/quickbit/'), name = 'quickbit' },
  }

  -- expand to include their subdirs too
  local project_dirs = {}
  for _, base in ipairs(base_dirs) do
    table.insert(project_dirs, base)
    for _, sub in ipairs(get_subdirs(base.path)) do
      table.insert(project_dirs, sub)
    end
  end

  pickers.new({}, {
    prompt_title = 'Projects',
    finder = finders.new_table {
      results = project_dirs,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry(prompt_bufnr).value
        actions.close(prompt_bufnr)
        vim.cmd('cd ' .. selection.path)
        -- If the current buffer is already in the selection path, don't search the jumplist
        if vim.fn.expand("%p"):find(selection.path, 1, true) then
          return true
        end
        local jumplist, idx = unpack(vim.fn.getjumplist())
        local found = false
        for pos = idx, 1, -1 do
          local entry = jumplist[pos]
          local bufnr = entry["bufnr"]
          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename:find(selection.path, 1, true) then
            vim.cmd("e " .. filename)
            found = true
            break
          end
        end
        if not found then
          vim.cmd("e .")
        end
      end)
      return true
    end,
  }):find()
end

vim.api.nvim_set_keymap('n', '<leader>sp', ':lua project_picker()<CR>', { noremap = true, silent = true })
