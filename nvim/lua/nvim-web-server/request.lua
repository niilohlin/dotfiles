local M = {}

local function parse_request_headers(request)
  local debug = require("nvim-web-server.server-log").debug
  local status = {}
  local headers = {}
  local lines = {}

  for line in request:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  if lines[1] then
    -- GET /test?a=b HTTP/1.1
    local method, path  lines[1]:match("(%w+) (HTTP/[%d%.]+)%s+(%d+)%s*(.*)")
    debug("lines[1]")
    debug(lines[1])
    if code then
      status.version = version
      status.code = tonumber(code)
      status.path = path
      status.method = method
    end
    debug("status")
    debug(status)
  end

  for i = 2, #lines do
    local line = lines[i]

    if line:match("^%s*$") then
      break
    end

    local name, value = line:match("([^:]+):%s*(.+)")
    if name and value then
      name = name:gsub("%s+$", ""):lower()
      value = value:gsub("%s+$", "")

      if headers[name] then
        if type(headers[name]) == "string" then
          headers[name] = { headers[name], value }
        else
          table.insert(headers[name], value)
        end
      else
        headers[name] = value
      end
    end
  end
  return { status = status, headers = headers, bad = false }
end


function M.process(raw_request, routes)
  Response = require("nvim-web-server.response")

  local request = parse_request_headers(
    raw_request
  )
  local response

  if request.bad then
    response = Response.bad()
  else
    assert(request.status.path ~= nil)
    local normalized = request.method .. " " .. request.status.path:gsub("?.*", ""):gsub("/+", "/")

    if not routes[normalized] then
      response = Response.not_found()
    else
      local query_string = request.status.path:match("%?(.*)")

      local query = {}
      if query_string then
        for key, value in query_string:gmatch("([^&=?]+)=([^&]*)") do
          query[key] = value
        end
      end

      local value = routes[normalized](query)

      response = Response.ok(
        value.content_type,
        value.content
      )
    end
  end

  return {
    request = request,
    response = response
  }
end

return M
