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
    end
  end
  vim.cmd("write")
end

function OpenVault()
  vim.cmd("tabnew")
  vim.cmd("lcd " .. vault_path)
  vim.cmd("e Home.md")
  TODOs()
  vim.keymap.set("n", "<leader>l", MarkAndUpdateTODO)
  -- vim.keymap.set("i", "<c-a>", function()
  --
  -- end, { buffer = true })
end

local base_html_template = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Vault</title>
  <style>
  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }
  </style>
</head>
<body style="
  background: #282828;
  color: #ebdbb2;
  font-family: 'SF Mono', 'Monaco', 'Cascadia Code', 'Roboto Mono', 'Consolas', 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.4;
  padding: 16px;
  margin: 0;
  min-height: 100vh;
">

<div style="
  max-width: 800px;
  margin: 0 auto;
">

<!-- Navigation -->
<nav style="
  background: #3c3836;
  padding: 12px 16px;
  margin-bottom: 20px;
  border-radius: 4px;
  border-left: 4px solid #b8bb26;
">
  <a href="/Users/niilohlin/Vault/Home.md" style="
    color: #83a598;
    text-decoration: none;
    margin-right: 16px;
    font-weight: bold;
    padding: 8px 12px;
    background: #504945;
    border-radius: 3px;
    display: inline-block;
    transition: background-color 0.2s;
  "
  onmouseover="this.style.backgroundColor='#665c54'"
  onmouseout="this.style.backgroundColor='#504945'">
    📁 Home
  </a>

  <a href="/" style="
    color: #fabd2f;
    text-decoration: none;
    font-weight: bold;
    padding: 8px 12px;
    background: #504945;
    border-radius: 3px;
    display: inline-block;
    transition: background-color 0.2s;
  "
  onmouseover="this.style.backgroundColor='#665c54'"
  onmouseout="this.style.backgroundColor='#504945'">
    ✅ TODOs
  </a>
</nav>

<!-- Content -->
<main style="
  background: #32302f;
  padding: 20px;
  border-radius: 6px;
  border: 1px solid #504945;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
">
%s
</main>

</div>

<style>
/* Links */
a {
  color: #83a598 !important;
  text-decoration: underline;
  transition: color 0.2s;
}

a:hover {
  color: #8ec07c !important;
}

a:visited {
  color: #d3869b !important;
}

/* Buttons */
button {
  background: #689d6a !important;
  color: #282828 !important;
  border: none !important;
  padding: 6px 12px !important;
  border-radius: 3px !important;
  font-family: inherit !important;
  font-size: 12px !important;
  font-weight: bold !important;
  cursor: pointer !important;
  margin-left: 8px !important;
  transition: background-color 0.2s !important;
}

button:hover {
  background: #8ec07c !important;
}

button:active {
  background: #b8bb26 !important;
}

/* Forms */
form {
  background: #3c3836 !important;
  padding: 12px !important;
  margin: 8px 0 !important;
  border-radius: 4px !important;
  border-left: 3px solid #fe8019 !important;
  display: flex !important;
  align-items: center !important;
  justify-content: space-between !important;
  flex-wrap: wrap !important;
}

/* Textareas */
textarea {
  background: #1d2021 !important;
  color: #ebdbb2 !important;
  border: 1px solid #504945 !important;
  padding: 12px !important;
  border-radius: 4px !important;
  font-family: inherit !important;
  font-size: 13px !important;
  width: 100%% !important;
  resize: vertical !important;
  margin-bottom: 12px !important;
}

textarea:focus {
  border-color: #83a598 !important;
  outline: none !important;
  box-shadow: 0 0 0 2px rgba(131, 165, 152, 0.2) !important;
}

/* Line breaks for spacing */
br {
  display: block !important;
  margin: 8px 0 !important;
  content: "" !important;
}

/* Mobile responsiveness */
@media (max-width: 600px) {
  body {
    padding: 12px !important;
    font-size: 13px !important;
  }

  nav {
    padding: 10px 12px !important;
  }

  nav a {
    display: block !important;
    margin: 4px 0 !important;
    margin-right: 0 !important;
    text-align: center !important;
  }

  main {
    padding: 16px !important;
  }

  form {
    flex-direction: column !important;
    align-items: stretch !important;
  }

  button {
    margin-left: 0 !important;
    margin-top: 8px !important;
    width: 100%% !important;
  }
}
</style>

</body>
</html>
]]

function ServeVault()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "markdown"
  Response = require("nvim-web-server.response")
  local routes = {
    ["GET /"] = function(_query, body, done)
      vim.schedule(function()
        local qf_items = FindDueTasks()

        local content = ""
        for _, item in ipairs(qf_items) do
          content = content .. ([[
            <a href="%s">
              %s
            </a>
            <br>
          ]]):format(item.filename, item.text)
        end

        local lines = vim.fn.readfile(vault_path .. "/Home.md")

        done(Response.ok(
          "text/html",
          base_html_template:format(content)
        ))
      end)
    end,
    ["POST /"] = function(_query, body, done) -- post set notes,
    end
  }

  local cmd = {
    "rg",
    "--files",
    "--type=markdown",
    vault_path,
  }

  for _, file_path in ipairs(vim.fn.systemlist(cmd)) do
    routes["GET " .. file_path] = function(_query, body, done)
      vim.schedule(function()
        local lines = vim.fn.readfile(file_path)
        local content = ([[<a href="%s/edit">edit</a><br>]]):format(file_path)
        for i, line in ipairs(lines) do
          if line:match("- %[ %] ") then
            content = content .. ([[
            <form action="%s" method="POST">
              %s <button type="submit" name="line" value="%d">done</button>
            </form>
            <br>
            ]]):format(file_path, line, i)
          else
            content = content .. line .. "<br>"
          end
        end
        done(
          Response.ok(
            "text/html",
            base_html_template:format(content)
          )
        )
      end)
    end
    routes["GET " .. file_path .. "/edit"] = function(_query, body, done)
      vim.schedule(function()
        local lines = vim.fn.readfile(file_path)
        local content = ([[
        <form action="%s/save" method="POST">
          <textarea id="content" name="content" rows="20" cols="50">%s</textarea>
          <br>
          <button type="submit">Save</button>
        </form>
        ]]):format(file_path, table.concat(lines, "\n"))
        done(
          Response.ok(
            "text/html",
            base_html_template:format(content)
          )
        )
      end)
    end
    routes["POST " .. file_path .. "/save"] = function(_query, body, done)
      vim.schedule(function()
        if body["content"] == nil then
          done(Response.bad("no content"))
          return
        end
        local temp_file = vim.fn.tempname()
        local backup_file = temp_file .. vim.fn.fnamemodify(file_path, ':t')
        local lines = vim.split(body["content"], "\r\n")
        vim.fn.writefile(lines, temp_file)
        vim.print("backing up to " .. backup_file)
        vim.fn.rename(file_path, backup_file)
        vim.fn.rename(temp_file, file_path)

        done(Response.see_other(file_path))
      end)
    end
    routes["POST " .. file_path] = function(_query, body, done)
      vim.schedule(function()
        vim.cmd.edit(file_path)
        vim.cmd(body["line"])
        MarkAndUpdateTODO()
        done(Response.see_other(file_path))
      end)
    end
  end

  require("nvim-web-server")
  Serve("0.0.0.0", 4999, routes)
end

vim.api.nvim_create_user_command("TODOs", TODOs, { nargs = "*" })
vim.api.nvim_create_user_command("Vault", OpenVault, { nargs = "*" })
vim.api.nvim_create_user_command("ServeVault", ServeVault, { nargs = "*" })
