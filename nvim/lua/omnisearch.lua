#!/usr/bin/env lua

local json = require("json")

local json_rpc = {}

function json_rpc.encode(data)
  local json_data = json.encode(data)
  local content_header = "Content-Length: " .. #json_data .. "\r\n\r\n"
  return content_header .. json_data
end

function json_rpc.decode_header(header)
  local sep = header:find("\n", 1, true) or #header

  local prefix = "Content-Length: "
  local number = header:sub(#prefix, sep):gsub("%s+", "")
  return tonumber(number) + 2
end

function json_rpc.decode(data)
  return json.decode(data:gsub("%s+", ""))
end

local log_file = io.open("/tmp/demo_lsp.log", "w+")

local function log(message)
  if log_file then
    if type(message) == "table" then
      message = json.encode(message)
    end
    log_file:write("[DEBUG] " .. message .. "\n")
    log_file:flush()
  end
end

local server = {
  registered_methods = {},
}

function server:start()
  ::continue::
  while true do
    log("reading from stdin")
    local header = io.read("*l")
    if header == nil then
      return
    end
    local to_read = json_rpc.decode_header(header)
    local body = io.read(to_read)
    log("body: " .. body)
    local decoded = json_rpc.decode(body)
    log("decoded " .. tostring(decoded))
    if not decoded then
      return
    end

    local method_name = decoded["method"]
    if method_name == nil then
      log("no method name")
      goto continue
    end

    local method = self.registered_methods[method_name]

    if method == nil then
      log("got unregistered method " .. method_name)
      goto continue
    end
    log("got method " .. decoded["method"])
    local response = method(decoded)

    if response then
      local encoded_response = json_rpc.encode(response)
      log("responding: " .. encoded_response)
      io.write(encoded_response)
      io.flush()
    end
  end
end

server.registered_methods = {
  ["initialize"] = function(params)
    return {
      jsonrpc = "2.0",
      id = params["id"],
      result = {
        serverInfo = {
          name = "demo_lsp_server",
          version = "0.1.0",
        },
        capabilities = {
          workspaceSymbolProvider = true,
        },
      },
    }
  end,
  ["workspace/symbol"] = function(params)
    local handle = io.popen(string.format("rg -n %q .", params.params.query))
    if not handle then
      log("fatal error, no handle")
      assert(false, "missing handle")
      return
    end

    local result = {}
    for line in handle:lines() do
      local file, line_nr = line:match("([^:]+):(%d+)")
      if line then
        table.insert(result, {
          name = line,
          kind = 12,
          location = {
            uri = "file://" .. file,
            range = {
              start = { line = tonumber(line_nr), character = 1 },
              ["end"] = { line = tonumber(line_nr), character = 1 },
            },
          },
        })
      end
    end
    handle:close()

    return {
      jsonrpc = "2.0",
      id = params["id"],
      result = result,
    }
  end,
}

server:start()
