local cjson = require "cjson"

-- enable passing the request body to lua
ngx.req.read_body()

-- decode the request body as JSON and catch any errors
local success, response = pcall(cjson.decode, ngx.var.request_body)

if success then
  -- we should proxy to a real backend here
  ngx.say('["bob","jim"]')
else
  -- if the request isn't valid JSON
  ngx.log(ngx.ERR, "invalid JSON request: " .. ngx.var.request_body)
  -- return a 400 indicating a client error
  ngx.status = ngx.HTTP_BAD_REQUEST
end
