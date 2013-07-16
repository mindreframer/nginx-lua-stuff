local riak = require "resty.riak.client"
local client = riak.new()
local ok, err = client:connect("127.0.0.1", 8087)
if not ok then
    ngx.log(ngx.ERR, "connect failed: " .. err)
end
local object = { key = "1", content = { value = "test", content_type = "text/plain" } }
local rc, err = client:store_object("test", object)
ngx.say(rc)
local object, err = client:get_object("test", "1")
if not object then
    ngx.say(err)
else
    ngx.say(object.content[1].value)
end
client:close()