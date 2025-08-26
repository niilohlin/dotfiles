--- An HTTP server for Neovim.
-- @module web-server
-- @author Gábor Nyéki
-- @license MIT
--

local default_config = {
  host = "127.0.0.1",
  port = 4999,
  log_filename = nil,
  log_each_request = false,
  log_views_period = 0,
  log_resource_use_period = 0,

  -- NOTE Keep-alive means that we run out of sockets real quick under
  -- load, and clients will begin getting "connection reset by peer"
  -- errors.
  --
  keep_alive = false
}

local Djotter = require("web-server.djotter")
local Path = require("web-server.path")
local cmd_error = require("web-server.common").cmd_error

local djotter = nil

--- Module class.
local M = {}

--- Server configuration.
-- @field host (string) IP address to listen on
-- @field port (integer) TCP port to listen on
-- @field[opt] log_filename (string) file to save the server's log
--   buffer
-- @field log_each_request (boolean) include requests in the server log
-- @field log_views_period (integer) interval at which to log view
--   counts for each path (in minutes)
-- @field keep_alive (boolean) whether to support Connection: keep-alive
-- @table config
M.config = vim.deepcopy(default_config)

--- Manages a buffer that contains the server log.
-- @field buf_id (integer) the ID of the log buffer
-- @field win_id (integer) the ID of the window in which the log buffer
--   is displayed
-- @field empty (boolean) whether the log buffer is currently empty
-- @field[opt] timer (uv_timer_t userdata) a timer that periodically
--   saves the buffer to the file specified by `log_filename` in the
--   server configuration
local Logger = {}

function Logger.new(filename)
  local buf_id = vim.api.nvim_create_buf(true, true)
  local timer = nil
  local empty = true

  if filename then
    -- Open `filename`.
    --
    vim.api.nvim_buf_call(buf_id, function()
      vim.cmd.edit(filename)
      empty = vim.fn.wordcount().bytes == 0
    end)

    -- Save the log buffer to `filename` every 5 minutes.
    --
    local dur_5m = 5 * 60 * 1000
    timer = vim.uv.new_timer()
    timer:start(dur_5m, dur_5m, vim.schedule_wrap(function()
      vim.api.nvim_buf_call(buf_id, function()
        vim.cmd.write()
      end)
    end))
  end

  local win_id = vim.api.nvim_open_win(buf_id, 0, { split = "above" })
  local state = {
    buf_id = buf_id,
    win_id = win_id,
    empty = empty,
    timer = timer
  }
  return setmetatable(state, { __index = Logger })
end

local function escape(str)
  return str:gsub("\r", "\\r"):gsub("\n", "\\n")
end

--- Adds a line to the log buffer, prepending a timestamp.
local function print_to_log(self, ...)
  local message = string.format(...)

  vim.schedule(function()
    local line = (
      vim.fn.strftime("[%Y-%m-%d %H:%M:%S] ") .. escape(message)
    )

    vim.api.nvim_buf_set_lines(self.buf_id, -1, -1, true, { line })

    if self.empty then
      -- If the log buffer was empty, then the first message was
      -- appended to an empty line.  We want to delete that empty
      -- line.
      vim.api.nvim_buf_set_lines(self.buf_id, 0, 1, true, {})
      self.empty = false
    end
  end)
end

--- Adds a piece of information to the log buffer.
-- @function Logger:info
Logger.info = print_to_log

--- Adds a client request to the log buffer.
-- Overwritten if `log_each_request` is `false` in the server
-- configuration.
-- @function Logger:request
Logger.request = print_to_log

local log = nil

-- TODO Wrap network I/O calls in `pcall()` in case of failure?

local function create_server(host, port, on_connect)
  log:info("Initializing server at %s:%d.", host, port)

  local server = vim.uv.new_tcp()
  server:bind(host, port)
  server:listen(1024, function(error)
    assert(not error, error)

    local socket = vim.uv.new_tcp()
    server:accept(socket)

    on_connect(socket)
  end)
  return server
end

--- An HTTP response.
-- @field status (integer) HTTP status code
-- @field value (string) response header and body to send to the client
local Response = { status = nil, value = nil }

local response_connection = "Connection: keep-alive\n"

--- Status code 200.
function Response.ok(proto, etag, content_type, content)
  return setmetatable({
    status = 200,
    value = string.format(
      "%s 200 OK\n" ..
      "Server: nvim-web-server\n" ..
      'ETag: "' .. etag .. '"\n' ..
      "Content-Type: %s\n" ..
      "Content-Length: %d\n" ..
      response_connection ..
      "\n" ..
      "%s",
      proto, content_type, content:len(), content
    )
  }, {
    __index = Response
  })
end

--- Status code 304.
function Response.not_modified(proto, etag)
  return setmetatable({
    status = 304,
    value = (
      proto .. " 304 Not Modified\n" ..
      "Server: nvim-web-server\n" ..
      'ETag: "' .. etag .. '"\n' ..
      response_connection ..
      "\n"
    )
  }, {
    __index = Response
  })
end

--- Status code 400.
function Response.bad(proto)
  local content = (
    "<!DOCTYPE html>" ..
    "<html>" ..
    "<head><title>Bad Request</title></head>" ..
    "<body>" ..
    "<center><h1>Bad Request</h1></center>" ..
    "<hr>" ..
    "<center>nvim-web-server</center>" ..
    "</body>" ..
    "</html>" ..
    "\n"
  )

  return setmetatable({
    status = 400,
    value = (
      proto .. " 400 Bad Request\n" ..
      "Server: nvim-web-server\n" ..
      "Content-Type: text/html\n" ..
      "Content-Length: " .. content:len() .. "\n" ..
      "Connection: close\n" ..
      "\n" ..
      content
    )
  }, {
    __index = Response
  })
end

--- Status code 404.
function Response.not_found(proto)
  local content = (
      "<!DOCTYPE html>" ..
      "<html>" ..
      "<head><title>Not Found</title></head>" ..
      "<body>" ..
      "<center><h1>Not Found</h1></center>" ..
      "<hr>" ..
      "<center>nvim-web-server</center>" ..
      "</body>" ..
      "</html>" ..
      "\n"
  )

  return setmetatable({
    status = 404,
    value = (
      proto .. " 404 Not Found\n" ..
      "Server: nvim-web-server\n" ..
      "Content-Type: text/html\n" ..
      "Content-Length: " .. content:len() .. "\n" ..
      response_connection ..
      "\n" ..
      content
    )
  }, {
    __index = Response
  })
end

--- Maps paths to content.
-- @field djotter (Djotter) converter from Djot to HTML
-- @field paths (@{paths}) the keys of this table are normalized paths,
--   the values are tables
local Routing = {}

--- Path routing table.
-- The keys are normalized paths.
-- The values are @{content} tables.
-- @table paths

--- Content table.
-- @field buf_id (integer)
-- @field buf_name (string)
-- @field buf_type (string) e.g., "text/djot", "image/png"
-- @field content_type (string) e.g., "text/html", "image/png"
-- @field content (string) message body to send to clients
-- @field etag (string) SHA-256 hash of content
-- @field autocmd_id (integer) ID of autocmd that updates content if
--   buffer changes
-- @table content

--- Constructs an empty routing table with a Djot converter.
function Routing.new(this_djotter)
  return setmetatable({
    djotter = this_djotter,
    paths = {}
  }, {
    __index = Routing
  })
end

function Routing:add_path(path, value)
  local normalized = Path.new(path).value

  if self.paths[normalized] then
    return false
  end

  value.buf_name = (
    vim.api.nvim_buf_get_name(value.buf_id) or "[unnamed]"
  )

  log:info(
    "Routing path '%s' to buffer '%s' (%s).",
    normalized,
    value.buf_name,
    value.buf_type
  )

  self.paths[normalized] = value

  return true
end

local function get_buffer_content(buf_id)
  return table.concat(
    vim.api.nvim_buf_get_lines(buf_id, 0, -1, true),
    "\n"
  ) .. "\n"
end

function Routing:update_content(buf_id)
  local path = self:get_path_by_buf_id(buf_id)

  assert(path, string.format(
    "Buffer %d has a callback attached but no path routed to it.",
    buf_id
  ))

  local value = self.paths[path]

  log:info(
    "Updating content for path '%s' from buffer '%s'.",
    path,
    value.buf_name
  )

  local buf_type = value.buf_type
  local content
  local content_type = buf_type

  if not buf_type:match("^text/") then
    local file_path = vim.api.nvim_buf_get_name(0)
    local handle, err = io.open(file_path)

    assert(not err, err)

    content = handle:read("*a")
    handle:close()
  else
    content = get_buffer_content(buf_id)
  end

  if buf_type == "text/djot" then
    content = self.djotter:to_html(content)
    content_type = "text/html"
  end

  -- For binary files, `content` is a blob, and `vim.fn.sha256`
  -- expects a string.
  --
  if vim.fn.type(content) == vim.v.t_blob then
    self.paths[path].etag = vim.fn.sha256(vim.fn.string(content))
  else
    self.paths[path].etag = vim.fn.sha256(content)
  end

  self.paths[path].content_type = content_type
  self.paths[path].content = content
end

function Routing:update_djot_paths()
  for _, value in pairs(self.paths) do
    if value.buf_type == "text/djot" then
      self:update_content(value.buf_id)
    end
  end
end

function Routing:delete_path(path)
  log:info("Deleting path '%s'.", path)

  local value = self.paths[path]

  vim.api.nvim_del_autocmd(value.autocmd_id)

  self.paths[path] = nil
end

function Routing:has_path(path)
  return self.paths[path] ~= nil
end

function Routing:has_buf_id(buf_id)
  for _, value in pairs(self.paths) do
    if value.buf_id == buf_id then
      return true
    end
  end
  return false
end

function Routing:get_path_by_buf_id(buf_id)
  for path, value in pairs(self.paths) do
    if value.buf_id == buf_id then
      return path
    end
  end
  return nil
end

local routing = nil

--- Parses the first line of the client's request.
-- @param request (string)
-- @return (string) first line of the client's request
-- @return (string) method (e.g., GET, POST)
-- @return (string) path requested by the client
-- @return (string) protocol (e.g., HTTP/1.1)
-- @return (boolean) whether the server considers the request malformed
local function process_request_line(request)
  local request_line = request:match("[^\r\n]*")
  local method = nil
  local path = nil
  local proto = nil
  local bad = false

  for word in request_line:gmatch("[^ ]+") do
    if not method then
      method = word
    elseif not path then
      path = word
    elseif not proto then
      proto = word
    else
      bad = true
      break
    end
  end

  if method ~= "GET" or not proto then
    bad = true
  end

  return request_line, method, path, proto, bad
end

--- Looks for "If-None-Match" in the client's request header.
-- @param request (string)
-- @return[1] (string) "tag" in "If-None-Match: tag"
-- @return[2] nil if the client sent no "If-None-Match"
local function process_request_header(request)
  for line in string.gmatch(request, "[^\r\n]+") do
    local field_name = line:match("^If%-None%-Match: *")

    if field_name then
      local value = line:sub(field_name:len() + 1):gsub('"', "")

      if value then
        return value
      end

      break
    end
  end
end

--- Parses the client's request and prepares the response.
-- @param request (string)
-- @return (table) request protocol, path, request line, and the
--   corresponding Response object
local function process_request(request)
  local request_line, _, path, proto, bad = process_request_line(
    request
  )
  local response

  if bad then
    response = Response.bad(proto or "HTTP/1.1")
  else
    local if_none_match = process_request_header(request)
    local normalized = Path.new(path).value

    if not routing:has_path(normalized) then
      response = Response.not_found(proto)
    else
      local value = routing.paths[normalized]

      if if_none_match and if_none_match == value.etag then
        response = Response.not_modified(proto, value.etag)
      else
        response = Response.ok(
          proto,
          value.etag,
          value.content_type,
          value.content
        )
      end
    end
  end

  return {
    proto = proto,
    path = path,
    request = request_line,
    response = response
  }
end

--- Command-line command to add the current buffer to the routing table.
function M.WSAddBuffer(path, opts_buf_type, bufnr)
  if not path:match("^/") then
    cmd_error("Path '%s' is not absolute.", path)
    return
  end

  local buf_id = bufnr or vim.fn.bufnr()
  local buf_type = opts_buf_type or "text/djot"
  local content_type = buf_type
  local content = nil
  local autocmd_id = vim.api.nvim_create_autocmd("BufWrite", {
    buffer = buf_id,
    callback = function(arg) routing:update_content(arg.buf) end
  })

  routing:add_path(path, {
    buf_id = buf_id,
    buf_type = buf_type,
    content_type = content_type,
    content = content,
    autocmd_id = autocmd_id
  })

  routing:update_content(buf_id)
end

--- Command-line command to delete a path from the routing table.
function M.WSDeletePath(path)
  if not routing:has_path(path) then
    cmd_error("Path '%s' does not exist.", path)
  else
    routing:delete_path(path)
  end
end

--- Command-line command to write all currently routed paths to the
-- server log.
function M.WSPaths()
  for path, value in pairs(routing.paths) do
    local length = 0
    if value.content then
      length = value.content:len()
    end

    log:info(
      "Path '%s' is routed to '%s' (%s, length %d).",
      path,
      value.buf_name,
      value.content_type,
      length
    )
  end
end

--- Command-line command to set the current buffer as the HTML template
-- used by the Djot converter.
function M.WSSetBufferAsTemplate(buffer)
  if djotter.template_buf_name then
    log:info(
      "Unsetting '%s' as template.", djotter.template_buf_name
    )

    vim.api.nvim_del_autocmd(djotter.template_autocmd_id)
  end

  local buf_id = buffer or vim.fn.bufnr()
  local buf_name = vim.api.nvim_buf_get_name(buf_id)

  log:info("Setting '%s' as template.", buf_name)

  local function update_template()
    djotter.template = get_buffer_content(buf_id)
    routing:update_djot_paths()
  end

  local autocmd_id = vim.api.nvim_create_autocmd("BufWrite", {
    buffer = buf_id,
    callback = update_template
  })

  djotter.template_buf_name = buf_name
  djotter.template_autocmd_id = autocmd_id

  update_template()
end

local function truncate(str, max_len)
  if str:len() > max_len then
    return str:sub(1, max_len) .. "..."
  end

  return str
end

--- Counts and logs views if a timer is running.
-- @field[opt] timer (uv_timer_t userdata) a timer that periodically
--   logs view counts and resets the counter
-- @field[opt] human_dur (string) human-readable representation of the
--   duration used by `timer`
-- @field count (table) keys are paths, values are view counts
-- @field increment (function) increments the count for the given path
--   if a timer is running
local Views = {}

function Views.new()
  local state = {
    timer = nil,
    human_dur = nil,
    count = {},
    increment = function() end
  }
  return setmetatable(state, { __index = Views })
end

--- Sets up a timer to log view counts.
-- @param dur_minutes (integer) log view counts at this interval
function Views:start_timer(dur_minutes)
  local units

  if dur_minutes % 1440 == 0 then
    units = dur_minutes / 1440
    self.human_dur = string.format("%d day", units)
  elseif dur_minutes % 60 == 0 then
    units = dur_minutes / 60
    self.human_dur = string.format("%d hour", units)
  else
    units = dur_minutes
    self.human_dur = string.format("%d minute", units)
  end

  if units > 1 then
    self.human_dur = self.human_dur .. "s"
  end

  local dur_ms = dur_minutes * 60 * 1000

  self.timer = vim.uv.new_timer()
  self.timer:start(dur_ms, dur_ms, vim.schedule_wrap(function()
    local had_views = false
    local log_views = function(...)
      if not had_views then
        had_views = true
        log:info("Views in the past %s:", self.human_dur)
      end
      log:info(...)
    end
    local not_found = { paths = 0, views = 0 }

    for path, count in pairs(self.count) do
      self.count[path] = nil

      if routing:has_path(path) then
        log_views("- %d for '%s'", count, path)
      else
        -- Rather than log each such path individually, only log
        -- them in the aggregate, in order to avoid DoS attacks
        -- that aim to fill up the log.
        --
        not_found.paths = not_found.paths + 1
        not_found.views = not_found.views + count
      end
    end

    if not_found.paths > 0 then
      log_views(
        "- %d for %d nonexistent %s",
        not_found.views,
        not_found.paths,
        not_found.paths > 1 and "paths" or "path"
      )
    end
  end))

  self.increment = function(this, path)
    this.count[path] = (this.count[path] or 0) + 1
  end
end

local views = nil

--- Periodically logs resource use if a timer is running.
-- @field[opt] timer (uv_timer_t userdata) a timer that periodically
--   logs resource use
local ResourceUse = {}

function ResourceUse.new()
  local state = { timer = nil }
  return setmetatable(state, { __index = ResourceUse })
end

--- Sets up a timer to log resource use.
-- @param dur_minutes (integer) log resource use at this interval
function ResourceUse:start_timer(dur_minutes)
  local dur_ms = dur_minutes * 60 * 1000

  self.timer = vim.uv.new_timer()
  self.timer:start(dur_ms, dur_ms, vim.schedule_wrap(function()
    local rusage = vim.uv.getrusage()
    local rss = { -- In MBs.
      current = vim.uv.resident_set_memory() / 1024 / 1024,
      max = rusage.maxrss / 1024
    }
    local cpu = { -- In seconds.
      user = rusage.utime.sec + rusage.utime.usec / 1000 / 1000,
      sys = rusage.stime.sec + rusage.stime.usec / 1000 / 1000
    }
    local ipc = { sent = rusage.msgsnd, recvd = rusage.msgrcv }
    local block = { in_ = rusage.inblock, out = rusage.oublock }
    local signals = rusage.nsignals
    local ctx = { vol = rusage.nvcsw, invol = rusage.nivcsw }

    log:info("Resource use:")
    log:info(
      "- RSS: %.2f MB (current), %.2f MB (max)",
      rss.current,
      rss.max
    )
    log:info("- CPU: %.2fs (user), %.2fs (sys)", cpu.user, cpu.sys)
    log:info("- IPC: %d (sent), %d (received)", ipc.sent, ipc.recvd)
    log:info("- Block ops: %d (in), %d (out)", block.in_, block.out)
    log:info("- Signals: %d", signals)
    log:info(
      "- Context switches: %d (voluntary), %d (involuntary)",
      ctx.vol,
      ctx.invol
    )
  end))
end

local resource_use = nil

--- Launches the HTTP server.
-- @param config (@{config})
-- @usage
-- -- Launch the web server on a different port from the default.
-- --
-- require("web-server").init({ port = 8080 })
--
-- -- Launch the web server with the log buffer saved to a file.
-- --
-- require("web-server").init({ log_filename = "server.log" })
--
function M.init(config)
  M.config = vim.tbl_extend("force", default_config, config or {})

  log = Logger.new(M.config.log_filename)
  djotter = Djotter.new()
  routing = Routing.new(djotter)
  views = Views.new()
  resource_use = ResourceUse.new()

  if not M.config.log_each_request then
    Logger.request = function() end
  end

  if M.config.log_views_period > 0 then
    views:start_timer(M.config.log_views_period)
  end

  if M.config.log_resource_use_period > 0 then
    resource_use:start_timer(M.config.log_resource_use_period)
  end

  if not M.config.keep_alive then
    response_connection = "Connection: close\n"
  end

  local host = M.config.host
  local port = M.config.port

  create_server(host, port, function(socket)
    local request = ""
    local result = nil

    socket:read_start(function(error, chunk)
      if error then
        log:info("Read error: '%s'.", error)
        socket:close()
        return
      elseif not chunk then
        socket:close()
        return
      end

      request = request .. chunk

      if request:len() > 2048 then
        result = {
          proto = "HTTP/1.1",
          request = request,
          response = Response.bad("HTTP/1.1")
        }
      elseif request:match("\r?\n\r?\n$") then
        result = process_request(request)
      end

      if result ~= nil then
        log:request(
          "%d %s %d %d '%s'",
          result.response.status,
          socket:getsockname().ip,
          request:len(),
          result.response.value:len(),
          truncate(result.request, 40)
        )
        socket:write(result.response.value)

        if result.response.status ~= 400 then
          views:increment(result.path)
        end

        local keep_alive = (
          M.config.keep_alive
          and result.proto ~= "HTTP/1.0"
          and result.response.status ~= 400
        )

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

--- Exported for testing.
M.internal = {
  escape = escape,
  process_request_line = process_request_line,
  process_request_header = process_request_header,
  truncate = truncate,
}
return M
