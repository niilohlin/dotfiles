local M = {}

function M.setup() end

local function install_rope(done)
  vim.fn.jobstart("python -m pip install rope", {
    cwd = vim.fn.getcwd(),
    on_exit = function(_, code, _)
      if code ~= 0 then
        print("Error occurred while installing rope")
      end
      done()
    end,
  })
end


local function import_assist(prefix, number, done)
  local python_code = [=[
import json
from rope.base.project import Project
from rope.contrib.autoimport import AutoImport
ai = AutoImport(Project("./"))
ai.generate_cache()
print(json.dumps([{k: v} for k, v in sorted(ai.import_assist("%s"))[0:%d]]))
]=]
  python_code = string.format(python_code, prefix, number):gsub("\n", "; ")

  vim.fn.jobstart("python -c '" .. python_code .. "'", {
    cwd = vim.fn.getcwd(),
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and table.concat(data) == "" then
        return
      end

      local modules = vim.json.decode(table.concat(data))
      done(modules)
    end,
    on_stderr = function(_, data, _)
      if #data > 0 then
        print(table.concat(data, "\n"))
      end
    end,
    on_exit = function(_, code, _)
      print("python code exit")
      if code ~= 0 then
        done({})
      end
    end,
  })
end

function M.AutoImport()
  local actions = {}
  local word_under_cursor = vim.fn.expand("<cword>")
  install_rope(function()
    import_assist(word_under_cursor, 5, function(modules)
      for _, pair in ipairs(modules) do
        local name, module = next(pair)
        if name ~= nil and module ~= nil then
          table.insert(actions, {
            title = "import " .. name .. " from " .. module,
            action = function()
              local last_import_line = 0
              for i = 1, vim.fn.getpos(".")[2] do
                local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
                if line:match("^from") or line:match("^import") then
                  last_import_line = i
                end
              end

              local import_line = "from " .. module .. " import " .. name
              if last_import_line == 0 then
                vim.api.nvim_buf_set_lines(0, 0, 0, false, { import_line })
              else
                vim.api.nvim_buf_set_lines(0, last_import_line, last_import_line, false, { import_line })
              end
              vim.cmd("norm " .. (last_import_line + 1) .. "G")
            end,
          })
        else
          print("No module or name found")
        end
      end

      local titles = {}
      for _, action in ipairs(actions) do
        table.insert(titles, action.title)
      end

      if #titles ~= 0 then
        vim.ui.select(titles, {
          prompt = "Choose an option: ",
        }, function(choice, idx)
            if choice then
              actions[idx].action()
            end
          end)
      else
        print("no imports found")
      end
      print("Import suggestions completed")
    end)
  end)
end

vim.api.nvim_create_user_command("RopeAutoImport", M.AutoImport, {})
vim.keymap.set("n", "<leader>ai", M.AutoImport)

return M
