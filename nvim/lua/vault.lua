local vault_path = "/Users/niilohlin/Vault"

function FindDueTasks()
  local cmd = {
    'rg',
    '--no-heading',
    '--with-filename',
    '--line-number',
    '--type=markdown',
    '^\\- \\[ \\] .* 📅 \\d+-\\d+-\\d+',
    vault_path
  }

  local qf_items = {}
  for _, task in ipairs(vim.fn.systemlist(cmd)) do
    local file, line, title = unpack(vim.split(task, ":"))

    if title == nil or title:find("✅") then
      goto continue
    end

    local year, month, day = title:match("📅 (%d%d%d%d)-(%d%d)-(%d%d)")

    if os.time({ year = year, month = month, day = day, hour = 0, min = 0, sec = 0 }) >= os.time() then
      goto continue
    end

    if os.time({ year = year, month = month, day = day, hour = 23, min = 59, sec = 59 }) >= os.time() then
      table.insert(qf_items, {
        filename = file,
        lnum = line,
        col = 4,
        text = title,
        type = "W",
      })
    else
      table.insert(qf_items, 1, {
        filename = file,
        lnum = line,
        col = 4,
        text = title,
        type = "E",
      })
    end

    ::continue::
  end

  return qf_items
end

function TODOs()
  local tasks = FindDueTasks()
  vim.fn.setqflist({}, "r", {
    items = tasks,
  })
  if #tasks > 0 then
    vim.cmd("copen | wincmd k")
  else
    vim.cmd("cclose")
  end
end

local function parse_task(task)
  local result = {}
  while true do
    local len = vim.fn.strchars(task)
    local index = nil
    for i = len - 1, 0, -1 do
      local char = vim.fn.strcharpart(task, i, 1)
      if char == "📅" or char == "✅" or char == "🔁" or char == "#" then
        index = i
        break
      end
    end
    if index == nil then
      break
    end
    local emoji = vim.fn.strcharpart(task, index, 1)
    result[emoji] = vim.fn.strcharpart(task, index + 1, vim.fn.strchars(task)):match("^%s*(.-)%s*$")
    task = vim.fn.strcharpart(task, 0, index - 1)
  end
  result["title"] = task
  return result
end

function MarkAndUpdateTODO()
  local current_line_text = vim.api.nvim_get_current_line()
  if not current_line_text:match("%s*- %[ %]") then
    vim.cmd("s/^\\(\\s*\\)/\\1- [ ] /")
  elseif current_line_text:find("✅") then
    print("todo: uncheck task")
  else
    vim.cmd("s/\\[ \\]/[x]/")
    vim.cmd(("s/$/ ✅ %s/"):format(os.date("%Y-%m-%d")))

    local parsed = parse_task(current_line_text)
    local recurring = parsed["🔁"]
    if recurring then
      local due_string = parsed["📅"]
      local year, month, day = due_string:match("(%d+)-(%d+)-(%d+)")
      local due_date = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day)
      })
      local next = nil
      local reference_date = due_date
      if recurring:find("when done") then
        reference_date = os.time()
      end

      if recurring:find("every day") then
        next = reference_date + 1 * 24 * 60 * 60
      elseif recurring:match("every %d+ days") then
        local days = recurring:match("every (%d+) days")
        next = reference_date + tonumber(days) * 24 * 60 * 60
      elseif recurring:match("every week") then
        next = reference_date + 7 * 24 * 60 * 60
      elseif recurring:match("every %d+ weeks") then
        local weeks = recurring:match("every (%d+) weeks")
        next = reference_date + tonumber(weeks) * 7 * 24 * 60 * 60
      elseif recurring:match("every month") then
        next = reference_date + 30 * 24 * 60 * 60
      elseif recurring:match("every %d+ months") then
        local months = recurring:match("every (%d+) months")
        next = reference_date + tonumber(months) * 30 * 24 * 60 * 60
      end
      if next == nil then
        vim.notify("failed to create recurring date")
        return
      end
      local next_string = os.date("%Y-%m-%d", next)
      local title = parsed["title"]
      if parsed["#"] then
        title = title .. " #" .. parsed["#"]
      end
      local new_task = ("%s 🔁 %s 📅 %s"):format(title, parsed["🔁"], next_string)

      vim.cmd(("put! = '%s'"):format(new_task))
      vim.cmd("write")
    end
  end
end

function OpenVault()
  vim.cmd("tabnew")
  vim.cmd("lcd " .. vault_path)
  vim.cmd("e Home.md")
  TODOs()
  vim.keymap.set("n", "<leader>l", MarkAndUpdateTODO, { buffer = true })
  -- vim.keymap.set("i", "<c-a>", function()
  --
  -- end, { buffer = true })
end

function ServeVault()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "markdown"
  local lines = vim.fn.readfile(vault_path .. "/Home.md")
  local routes = {
    ["GET /"] = function(_query)
      local qf_items = FindDueTasks()
      return {
        content_type = "text/html",
        content = table.concat(vim.tbl_map(function(qf_item) return qf_item.text end, qf_items))
      }
    end
  }
  require("nvim-web-server")
  Serve("127.0.0.1", 4999, routes)

  -- "<!DOCTYPE html>",
  -- "<html lang=\"en\">",
  -- "<head>",
  -- "<meta charset=\"UTF-8\">",
  -- "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
  -- "<meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\">",
  -- "<title>{{ title }}</title>",
  -- "</head>",
  -- "<body>",
  -- "{{ content }}",
  -- "</body>",
  -- "</html>",
end

vim.api.nvim_create_user_command("TODOs", TODOs, { nargs = "*" })
vim.api.nvim_create_user_command("Vault", OpenVault, { nargs = "*" })
vim.api.nvim_create_user_command("ServeVault", ServeVault, { nargs = "*" })
