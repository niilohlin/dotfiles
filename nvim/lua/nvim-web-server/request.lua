local M = {}

local function parse_http_request(request_string)
  local lines = {}
  local result = {
    line = {},
    headers = {},
    body = {}
  }


  for line in vim.gsplit(request_string, "\r\n") do
    table.insert(lines, line)
  end

  if #lines == 0 then
    return result
  end

  local request_line = lines[1]
  local method, path = request_line:match("^(%S+)%s+(%S+)")

  result.line.method = method
  result.line.path = path:gsub("%%20", " ")
  result.line.protocol = "HTTP/1.1"

  local body_start_index = nil
  local i = 2

  while i <= #lines do
    local line = lines[i]
    if line == "" then
      body_start_index = i + 1
      break
    end

    local name, value = line:match("^([^:]+):%s*(.*)$")
    if name and value then
      result.headers[name:lower()] = value
    end

    i = i + 1
  end

  if body_start_index and body_start_index <= #lines then
    local body_content = ""
    for j = body_start_index, #lines do
      body_content = body_content .. lines[j]
      if j < #lines then
        body_content = body_content .. "\n"
      end
    end

    for pair in body_content:gmatch("[^&\n]+") do
      local key, value = pair:match("^([^=]+)=(.*)$")
      if key and value then
        -- URL decode if needed (basic implementation)
        key = key:gsub("+", " "):gsub("%%(%x%x)", function(hex)
          return string.char(tonumber(hex, 16))
        end)
        value = value:gsub("+", " "):gsub("%%(%x%x)", function(hex)
          return string.char(tonumber(hex, 16))
        end)

        result.body[key] = value
      end
    end
  end

  return result
end

function M.process(raw_request, routes, done)
  Response = require("nvim-web-server.response")
  local request = parse_http_request(
    raw_request
  )

  if request.bad then -- figure out how to check this
    -- response = Response.bad()
  else
    assert(request.line.path ~= nil)
    local normalized = request.line.method .. " " .. request.line.path:gsub("?.*", ""):gsub("/+", "/")

    if not routes[normalized] then
      done(
        {
          request = request,
          response = Response.not_found()
        }
      )
    else
      local query_string = request.line.path:match("%?(.*)")

      local query = {}
      if query_string then
        for key, value in query_string:gmatch("([^&=?]+)=([^&]*)") do
          query[key] = value
        end
      end

      routes[normalized](query, request.body, function(response)
        done(
          {
            request = request,
            response = response
          }
        )
      end)
    end
  end
end

return M
