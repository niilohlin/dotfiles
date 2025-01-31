-- A more lightweight harpoon, based on the loclist
local M = {}

function M.add_current_loc_to_loclist()
  local bufnr = vim.api.nvim_get_current_buf()

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1]
  local col = pos[2]

  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  local loclist = vim.fn.getloclist(0)

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
