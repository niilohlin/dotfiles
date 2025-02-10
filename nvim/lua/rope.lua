local M = {}

function M.setup()
end

local null_ls = require("null-ls")

local function import_assist(prefix, number, done)
  local python_code = 'print(__import__("json").dumps([{k: v} for k, v in sorted(__import__("rope.contrib.autoimport", fromlist="AutoImport").AutoImport(__import__("rope.base.project", fromlist="Project").Project("./")).import_assist("' .. prefix .. '"))[0:' .. number .. ']]))'
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
      if code ~= 0 then
        done({})
      end
    end
  })
end


M.auto_import = {
  method = null_ls.methods.CODE_ACTION,
  filetypes = { "python" },
  generator = {
    fn = function(params, done)
      local actions = {}
      local is_undefined = false
      for _, diag in ipairs(params.lsp_params.context.diagnostics) do
        if diag.code == "undefined-variable" or diag.code == "name-defined" then
          is_undefined = true
        end
      end
      if not is_undefined then
        done({})
        return
      end

      local word_under_cursor = vim.fn.expand("<cword>")

      import_assist(word_under_cursor, 5, function(modules)
        for _, pair in ipairs(modules) do
          local name, module = next(pair)
          if name ~= nil and module ~= nil then
            table.insert(actions, {
              title = "import " .. name .. " from " .. module,
              action = function()
                local last_import_line = 0
                for i = 1, params.row do
                  local line = vim.api.nvim_buf_get_lines(params.bufnr, i, i + 1, false)[1]
                  if line:match("^from") or line:match("^import") then
                    last_import_line = i
                  end
                end

                local import_line = "from " .. module .. " import " .. name
                if last_import_line == 0 then
                  vim.api.nvim_buf_set_lines(params.bufnr, last_import_line, last_import_line + 1, false, { import_line })
                else
                  vim.api.nvim_buf_set_lines(params.bufnr, last_import_line + 1, last_import_line + 1, false, { import_line })
                end
              end,
            })
          end
        end

        done(actions)
      end)
    end,
    async = true,
  }
}



M.completion = {
  method = null_ls.methods.COMPLETION,
  filetypes = { "python" },
  generator = {
    fn = function(params, done)
      local line_to_cursor = params.content[params.row]:sub(1, params.col)
      local prefix = line_to_cursor:match("[a-zA-Z_][a-zA-Z0-9_]*$") or ""
      local start_col = params.col - #prefix

      import_assist(prefix, 10, function(modules)
        local items = {}
        for _, pair in ipairs(modules) do
          local name, module = next(pair)
          local insertText = name
          local textEdit = {
            range = {
              start = { line = params.row - 1, character = start_col },
              ["end"] = { line = params.row - 1, character = params.col - start_col },
            },
            newText = insertText,
          }


          items[#items + 1] = {
            label = name,
            kind = vim.lsp.protocol.CompletionItemKind.Text,
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.Plain,
            detail = module,
            insertText = insertText,
            textEdit = textEdit,
            additionalTextEdits = nil -- does not seem to be working :(
          }
        end
        done({ { items = items, isIncomplete = #items == 0 } })
      end)

    end,
    async = true,
  }
}

function M.GenerateRopeCache(params)
  vim.fn.jobstart("python -m pip install rope", {
    cwd = vim.fn.getcwd(),
    on_exit = function(_, code, _)
      if code ~= 0 then
        print("Error occurred while installing rope")
      end
      local python_code = '__import__("rope.contrib.autoimport", fromlist="AutoImport").AutoImport(__import__("rope.base.project", fromlist="Project").Project("./")).generate_cache()'
      vim.fn.jobstart("python -c '" .. python_code .. "'", {
        cwd = vim.fn.getcwd(),
        on_stderr = function(_, data, _)
          if #data > 0 then
            print(table.concat(data, "\n"))
          end
        end,
        on_exit = function(_, code, _)
          if code ~= 0 then
            print("Error occurred while generating rope cache")
            return
          end
          print("successfully generated python cache")
        end
      })
    end,
  })
end

return M
