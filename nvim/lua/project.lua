local M = {}

-- project file located at ~/.local/share/nvim/projects.lua

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
  if vim.fn.isdirectory(vim.fn.expand(project.path .. "/venv")) == 1 then
    if not vim.env.VIRTUAL_ENV then
      local full_path = vim.fn.expand(project.path)
      vim.env.PYTHONPATH = full_path
      vim.env.VIRTUAL_ENV = full_path .. "/venv"
      vim.env.PATH = full_path .. "/venv/bin:" .. vim.env.PATH
    end
    vim.fn.system("python -m pip install rope debugpy bpython")
  end

  project.setup()
  vim.o.titlestring = name
end

function M.setup(opts)
  local augroup = vim.api.nvim_create_augroup("nvimproj", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = function()
      local project_name = M.find_project_file(vim.fn.getcwd())
      local projects = M.all_projects()

      if
          project_name
          and projects[project_name]
          and projects[project_name]["setup"]
          and vim.o.titlestring ~= project_name
      then
        M.load(project_name, projects[project_name])
      else
      end
    end,
    group = augroup,
  })
end

return M
