local riak = require "resty.riak"
local client = riak.new()
local ok, err = client:connect("127.0.0.1", 8087)
if not ok then
    ngx.log(ngx.ERR, "connect failed: " .. err)
end

local info, err = client:get_server_info()
ngx.say(type(info))
ngx.say(type(info.node))
ngx.say(type(info.server_version))
ngx.say(err)

local id, err = client:get_client_id()
ngx.say(type(id))
ngx.say(err)

local rc, err = client:ping()
ngx.say(rc)
ngx.say(err)

client:close()