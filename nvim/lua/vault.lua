local M = {}

local vault_path = "/Users/niilohlin/Vault"

function M.FindDueTasks()
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

    local year, month, day = title:match("📅 (%d%d%d%d)-(%d%d)-(%d%d)")

    if os.time({ year = year, month = month, day = day}) >= os.time() then
      goto continue
    end
    if title == nil or title:find("✅") then
      goto continue
    end

    table.insert(qf_items, {
      filename = file,
      lnum = line,
      col = 4,
      text = title,
      type = "W",
    })

    ::continue::
  end

  vim.fn.setqflist({}, "r", {
    items = qf_items,
  })

  vim.cmd("copen")
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

function M.OpenVault()
  vim.cmd("tabnew")
  vim.cmd("lcd " .. vault_path)
  vim.cmd("e Home.md")
  vim.cmd("iabbrev due 📅")
  vim.cmd("iabbrev recurring 🔁")
  M.FindDueTasks()
  vim.keymap.set("n", "<leader>l", function ()
    local current_line_text = vim.api.nvim_get_current_line()
    if current_line_text:find("✅") then
      --vim.cmd((":silent edit %s | %ds/[x]/[ ]/ | write | bdelete"):format(file, row))
      print("todo: uncheck task")
    else
      vim.cmd("s/\\[ \\]/[x]/")
      vim.cmd(("s/$/ ✅ %s/"):format(os.date("%Y-%m-%d")))

      local parsed = parse_task(current_line_text)
      local recurring = parsed["🔁"]
      local due_string = parsed["📅"]
      local year, month, day = due_string:match("(%d+)-(%d+)-(%d+)")
      local due_date = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day)
      })

      if recurring then
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
      end
    end
  end)
end

vim.api.nvim_create_user_command("Vault", M.OpenVault, { nargs = "*" })

return M
