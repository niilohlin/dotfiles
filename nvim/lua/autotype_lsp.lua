---@type table<vim.lsp.protocol.Method, fun(params: table, callback:fun(err: lsp.ResponseError?, result: any))>
local handlers = {}
local ms = vim.lsp.protocol.Methods

---@param buf integer
---@return integer? client_id
local function start_lsp(buf)
   ---@type vim.lsp.ClientConfig
   local client_cfg = {
      name = "autotype-lsp",
      cmd = function()
         return {
            request = function(method, params, callback)
               if handlers[method] then
                  handlers[method](params, callback)
               end
            end,
            notify = function() end,
            is_closing = function() end,
            terminate = function() end,
         }
      end,
   }

   return vim.lsp.start(client_cfg, { bufnr = buf, silent = false })
end

vim.api.nvim_create_autocmd("FileType", {
   pattern = { "python" },
   callback = function(ev)
      start_lsp(ev.buf)
   end,
})

---@type lsp.InitializeResult
local initializeResult = {
   capabilities = {
      completionProvider = {
         triggerCharacters = { ":", " " },
      },
   },
   serverInfo = {
      name = "autotype-lsp",
      version = "0.0.1",
   },
}

handlers[ms.initialize] = function(_, callback)
   callback(nil, initializeResult)
end

local function to_pascal_case(str)
   return str:gsub("(%a)([%w_]*)", function(first, rest)
      return first:upper() .. rest:lower()
   end):gsub("_", "")
end

handlers[ms.textDocument_completion] = function(params, callback)
   local row = params.position.line
   local col = params.position.character
   local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]

   -- match "word: typed_prefix" pattern before cursor
   local word, prefix = line:sub(1, col):match("([%a][%w_]*):%s+([%a][%w_]*)$")
   if not word then
      return callback(nil, { items = {}, isIncomplete = false })
   end

   local pascal = to_pascal_case(word)
   -- filter: only suggest if pascal starts with what's already typed
   if not vim.startswith(pascal:lower(), prefix:lower()) then
      return callback(nil, { items = {}, isIncomplete = false })
   end

   callback(nil, {
      items = {
         {
            label = pascal,
            kind = vim.lsp.protocol.CompletionItemKind.Text,
            textEdit = {
               newText = pascal,
               range = {
                  start   = { line = row, character = col - #prefix },
                  ["end"] = { line = row, character = col },
               },
            },
         },
      },
      isIncomplete = false,
   })
end
