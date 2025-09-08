local Response = { status = nil, value = nil }

local response_connection = "Connection: keep-alive\n"

function Response.ok(content_type, content)
  return {
    status = 200,
    value = string.format(
      "HTTP/1.1 200 OK\n" ..
      "Server: nvim-web-server\n" ..
      "Content-Type: %s\n" ..
      "Content-Length: %d\n" ..
      response_connection ..
      "\n" ..
      "%s",
      content_type, content:len(), content
    )
  }
end

function Response.bad(reason)
  local content = (
    "<!DOCTYPE html>" ..
    "<html>" ..
    "<head><title>Bad Request</title></head>" ..
    "<body>" ..
    "<center><h1>Bad Request</h1></center>" ..
    reason .. "<br>" ..
    "<hr>" ..
    "<center>nvim-web-server</center>" ..
    "</body>" ..
    "</html>" ..
    "\n"
  )

  return {
    status = 400,
    value = (
      "HTTP/1.1 400 Bad Request\n" ..
      "Server: nvim-web-server\n" ..
      "Content-Type: text/html\n" ..
      "Content-Length: " .. content:len() .. "\n" ..
      "Connection: close\n" ..
      "X-Error-Message: " .. reason .. "\n" ..
      "\n" ..
      content
    )
  }
end

--- Status code 303.
function Response.see_other(location)
  return {
    status = 303,
    value = (
      "HTTP/1.1 303 See Other\r\n" ..
      "Location: " .. location .. "\r\n" ..
      "Server: nvim-web-server\r\n" ..
      "Content-Length: 0\r\n" ..
      "Cache-Control: no-cache, no-store, must-revalidate\r\n" ..
      "Pragma: no-cache\r\n" ..
      "Expires: 0\r\n" ..
      response_connection ..
      "\r\n"
    )
  }
end

--- Status code 304.
function Response.not_modified()
  return {
    status = 304,
    value = (
      "HTTP/1.1 304 Not Modified\n" ..
      "Server: nvim-web-server\n" ..
      response_connection ..
      "\n"
    )
  }
end

--- Status code 404.
function Response.not_found()
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

  return {
    status = 404,
    value = (
      "HTTP/1.1 404 Not Found\n" ..
      "Server: nvim-web-server\n" ..
      "Content-Type: text/html\n" ..
      "Content-Length: " .. content:len() .. "\n" ..
      response_connection ..
      "\n" ..
      content
    )
  }
end

return Response
