local _ = require("underscore")
local table = table
local Response = {}
Response.__index = Response
Response.__tostring = function(self)
  return "Response"
end

function parse_arguments(...)
  local args = {...}
  if #args == 3 then
    return args[1], args[2], args[3]
  elseif #args == 2 then
    return args[1], {}, args[2]
  elseif #args == 1 then
    if type(args[1]) == "number" then
      return args[1], {}, " "
    else
      return 200, {}, args[1]
    end
  else
    return 200, {}, " "
  end
end

function Response:new(...)
  local status, headers, body = parse_arguments(...)
  if(ngx.req.get_method() == "HEAD") then
    body = ""
  end
  return setmetatable({
    status=status,
    body=body,
    headers=headers
  }, self)
end

function Response:send()
  ngx.status = self.status
  for name, value in pairs(self.headers) do
    ngx.header[name] = value
  end
  ngx.say(self.body)
end

return Response
