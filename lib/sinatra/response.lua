local class = require '30log'
local _ = require("underscore")
local table = table
local Response = class {}
Response.__name = "Response"

local function parse_arguments(args)
  if _.isString(args) then
    return nil, nil, args
  elseif _.isNumber(args) then
    return args, nil, nil
  elseif _.isArray(args) and _.isNumber(args[1]) then
    local status, body, headers = _.shift(args), _.pop(args), unpack(args)
    return status, headers, body
  else
    return nil, nil, nil
  end
end

function Response:__init(args)
  local status, headers, body = parse_arguments(args)
  if(ngx and ngx.var.request_method == "HEAD") then
    body = ""
  end
  self.status = status or 200
  self.body = body or " "
  self.headers = headers or {}
end

function Response:update(args)
  local status, headers, body = parse_arguments(args)
  if(ngx and ngx.var.request_method == "HEAD") then
    body = ""
  end
  self.status = status or self.status
  self.headers = headers or self.headers
  self.body = body or self.body
end

function Response:finish()
  ngx.status = self.status
  for name, value in pairs(self.headers) do
    ngx.header[name] = value
  end
  if(_.isFunction(self.body)) then
    for str in self.body do
      ngx.print(str)
    end
  else
    ngx.print(self.body)
  end
end

return Response
