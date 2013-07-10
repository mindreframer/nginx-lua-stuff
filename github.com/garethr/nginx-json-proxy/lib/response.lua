local cjson = require "cjson"

-- make a subrequest, passing the request body
res = ngx.location.capture(
  "/request",
  { method = ngx.HTTP_POST, body = ngx.var.request_body }
)

-- if the subrequest errors
if res.status == ngx.HTTP_OK then
else
  ngx.status = ngx.HTTP_BAD_REQUEST
  ngx.say("invalid request")
  -- terminate the request
  return
end

-- if we have a valid request, decode response as JSON
local success, response = pcall(cjson.decode, res.body)

if success then
  -- if valid JSON just pass through the response
  ngx.status = res.status
  ngx.say(res.body)
else
  -- if invalid JSON then error
  ngx.log(ngx.ERR, "invalid JSON response" .. res.body)
  ngx.status = ngx.HTTP_BAD_REQUEST
  ngx.say("invalid response")
end
