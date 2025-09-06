local debug = require("nvim-web-server.server-log").debug

local function create_server(host, port, on_connect)
  debug(("Initializing server at %s:%d."):format(host, port))

  local server = vim.uv.new_tcp()
  assert(server ~= nil)
  server:bind(host, port)
  server:listen(1024, function(error)
    assert(not error, error)

    local socket = vim.uv.new_tcp()
    assert(socket ~= nil)
    server:accept(socket)

    on_connect(socket)
  end)
  return server
end


function Serve(host, port, routes)
  host = host or "127.0.0.1"
  port = port or 4999
  routes = routes or {
    -- ["GET /"] = function()
    --   return {
    --     content_type = "text/html",
    --     content = "hello"
    --   }
    -- end,
    -- ["GET /test"] = function(query)
    --   return {
    --     content_type = "text/html",
    --     content = "test, query " .. vim.inspect(query)
    --   }
    -- end,
    --
    -- ["POST /poster"] = function(_query, body)
    --   return {
    --     content_type = "text/html",
    --     content = "poster, body " .. vim.inspect(body)
    --   }
    -- end
  }

  create_server(host, port, function(socket)
    debug(("creating server %s %d"):format(host, port))
    Request = require("nvim-web-server.request")
    local request = ""
    local result = nil

    socket:read_start(function(error, chunk)
      debug(("reading chunk %s %s"):format(error, chunk))
      if error then
        debug(("Read error: '%s'."):format(error))
        socket:close()
        return
      elseif not chunk then
        socket:close()
        return
      end

      request = request .. chunk

      debug("request chunk")
      debug(request)
      if request:match("\r?\n\r?\n") then
        result = Request.process(request, routes)
      end

      if result ~= nil then
        debug("result")
        debug(result)
        socket:write(result.response.value)

        local keep_alive = result.response.status ~= 400

        if keep_alive then
          request = ""
          result = nil
        else
          socket:read_stop()
          socket:close()
        end
      end
    end)
  end)
end
