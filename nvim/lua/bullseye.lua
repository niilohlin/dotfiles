-- A more lightweight harpoon, based on the loclist
local M = {}

function M.toggle_current_loc_to_loclist()

  -- local loclist_win = vim.fn.getloclist(0, {winid = true}).winid
  -- if loclist_win == 0 then
  --   vim.defer_fn(function ()
  --     vim.cmd("lopen")
  --   end, 0)
  --   return
  -- end

  local loclist = vim.fn.getloclist(0)

  local bufnr = vim.api.nvim_get_current_buf()

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1]
  local col = pos[2]

  if vim.bo.filetype == "qf" then
    local line_under_cursor = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    for i, entry in ipairs(loclist) do
      if line_under_cursor:find(entry.text) then
        table.remove(loclist, i)
        vim.fn.setloclist(0, loclist, 'r')
        return
      end
    end
    return
  end

  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

  vim.defer_fn(function ()
    local found = false
    for _, entry in ipairs(loclist) do
      if entry.text:sub(1, 4) == "<-- " and (entry.bufnr == bufnr or entry.filename == filename) then
        entry.lnum = line
        entry.col = col
        found = true
        break
      end
    end
    vim.fn.setloclist(0, loclist, 'r')

    if not found then
      local entry = {
        bufnr = bufnr,
        lnum = line,
        col = col + 1,
        text = "<-- " .. (filename or "unnamed buffer"),
      }
      vim.fn.setloclist(0, {entry}, 'a')
    end
  end, 0)
end

local function store_offset()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local pos = vim.api.nvim_win_get_cursor(0)

  local loclist = vim.fn.getloclist(0)
  -- do this garbage to get the loclist not to spaz out
  vim.defer_fn(function ()
    for _, entry in ipairs(loclist) do
      if entry.text:sub(1, 4) == "<-- " and (entry.bufnr == bufnr or entry.filename == filename) then
        entry.lnum = pos[1]
        entry.col = pos[2] + 1
      end
    end
    vim.fn.setloclist(0, loclist, 'r')
  end, 0)
end

local augroup = vim.api.nvim_create_augroup(
  "bullseye",
  { clear = true }
)

vim.api.nvim_create_autocmd({ "BufLeave", "VimLeave" }, {
  callback = function()
    if vim.bo.filetype ~= "qf" then
      store_offset()
    end
  end,
  group = augroup,
})

return M
