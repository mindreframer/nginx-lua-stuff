local Utils = {}

function Utils.escape(str)
  if ngx and ngx.escape_uri then
    return ngx.escape_uri(str)
  else
    return str:gsub("\n", "\r\n"):gsub("([^%w ])", function (c)
      return string.format("%%%02X", string.byte(c))
    end):gsub(" ", "+")
  end
end

function Utils.unescape(str)
  if ngx and ngx.escape_uri then
    return ngx.escape_uri(str)
  else
    return(str:gsub("+", " "):gsub("%%(%x%x)", function (h)
      return string.char(tonumber(h, 16))
    end))
  end
end

return Utils
