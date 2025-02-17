local M = {}

---@return table
function M.all_projects()
  local project_file = vim.fn.stdpath("data") .. "/projects.lua"
  -- create file if not exist
  if vim.fn.filereadable(project_file) == 0 then
    vim.fn.writefile({ "local M = {}; return M" }, project_file)
  end

  return dofile(project_file)
end

---@param path string
---@return string|nil
function M.find_project_file(path)
  local projects = M.all_projects()
  for project in pairs(projects) do
    if vim.fn.expand(projects[project].path) == vim.fn.expand(path) then
      return project
    end
  end
  return nil
end

function M.load(name, project)
  project.setup()
  vim.api.nvim_command("let &titlestring = '" .. name .. "'")
end

function M.setup(opts)
  local augroup = vim.api.nvim_create_augroup("nvimproj", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "DirChanged" }, {
    callback = function()
      local project_name = M.find_project_file(vim.fn.getcwd())
      local projects = M.all_projects()
      if project_name and projects[project_name] and projects[project_name]["setup"] then
        M.load(project_name, projects[project_name])
      else
      end
    end,
    group = augroup,
  })
end

return M
