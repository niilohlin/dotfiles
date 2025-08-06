-- tmux sessionizer like search but in vim

-- close all windows when changing directory. The diagnostics windows can sometimes get stuck.
vim.api.nvim_create_autocmd({ "DirChanged" }, {
  group = vim.api.nvim_create_augroup("DirChangedWindows", { clear = true }),
  callback = function(ev)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative == "win" then
        vim.api.nvim_win_close(win, false)
      end
    end
  end
})

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

  local items = vim.tbl_map(function(entry)
    return {
      text = entry.name,
      value = entry,
      display = entry.name,
      ordinal = entry.name,
    }
  end, project_dirs)

  Snacks.picker.pick({
    items = items,
    format = function(item)
      return {
        { item.text },
      }
    end,
    layout = { preset = "select", preview = nil },
    confirm = function(picker, item)
      picker:close()
      local selection = item.value
      vim.cmd('cd ' .. selection.path)

      local current = vim.fn.expand('%:p')
      if current:find(selection.path, 1, true) then
        return
      end

      local jumplist, idx = unpack(vim.fn.getjumplist())
      local found = false
      for pos = idx, 1, -1 do
        local ent = jumplist[pos]
        local bufnr = ent.bufnr
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname:find(selection.path, 1, true) then
          vim.cmd('e ' .. fname)
          found = true
          break
        end
      end

      if not found then
        vim.cmd('e .')
      end
    end,
  })
end

vim.keymap.set('n', '<leader>sp', project_picker, { noremap = true, silent = true, desc = 'Pick Project (Snacks)' })

