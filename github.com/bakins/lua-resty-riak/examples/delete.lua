local riak = require "resty.riak"
local client = riak.new()
local ok, err = client:connect("127.0.0.1", 8087)
if not ok then
    ngx.log(ngx.ERR, "connect failed: " .. err)
end
local bucket = client:bucket("test")
local object = bucket:new("1")
object.value = "test"
object.content_type = "text/plain"
local rc, err = object:store()
ngx.say(rc)
local rc, err = bucket:delete("1")
ngx.say(rc)
client:close()