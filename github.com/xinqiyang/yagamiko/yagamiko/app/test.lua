#!/usr/bin/env lua

module("test", package.seeall)

local util    = require('yagami.util')
local ygmutil = require('ygmutils')
local JSON = require("cjson")
local Redis = require("resty.redis")

-- use native redis class
local ygmredis = require("yagami.redis")


function test(req,resp)
    

    local s = require('storage')
    local code = s.save()
    ngx.say(code)
    ngx.exit(200)
    --k = 'testabc'; v = 'valuetest'
    --ygmredis:redis_slave()
    -- test redis class
    --local r = ygmredis:redis_master()
    --r:set(k,v)
    --ngx.say(r:get(k))
    --util.traceback()
    --ngx.exit(200)

    --local key = 'redis_set01'
    --local value = util.get_config(key)
    --resp:writeln(value.master)
    --local host,port = util.splitSlave(value.slave)
    --ngx.say(host)
    --ngx.say(port)
    --ngx.exit(200)
end



function hello(req, resp, name)
    logger:i("hello request started!")
    if req.method=='GET' then
        resp:writeln('Host: ' .. req.host)
        resp:writeln('Hello, ' .. ngx.unescape_uri(name))
        resp:writeln('name, ' .. req.uri_args['name'])
        resp.headers['Content-Type'] = 'application/json'
        resp:writeln(JSON.encode(req.uri_args))

        resp:writeln({{'a','c',{'d','e', {'f'}}},'b'})
    elseif req.method=='POST' then
        -- resp:writeln('POST to Host: ' .. req.host)
        req:read_body()
        resp.headers['Content-Type'] = 'application/json'
        resp:writeln(JSON.encode(req.post_args))
    end
    logger:i("hello request completed!")
end


function longtext(req, resp)
    local a = string.rep("xxxxxxxxxx", 100)
    resp:writeln(a)
    resp:finish()
    
    local red = Redis:new()
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        resp:writeln({"failed to connect: ", err})
    end

    --red:set_timeout(10)

    for i=1,10 do
        local k = "foo"..tostring(i)
        red:set(k, "bar"..tostring(i))
        local v = red:get(k)
        ngx.log(ngx.ERR, "i:"..tostring(i), ", v:", v)
        
        ngx.sleep(1)
    end
end


function ltp(req, resp)
    resp:ltp("ltp.html", {v="hello, yagami!"})
end

