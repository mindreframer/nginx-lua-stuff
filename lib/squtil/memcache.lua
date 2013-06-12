local setmetatable = setmetatable
local string = string
local error = error
local require = require
local ngx = ngx
module(...)

_VERSION = '0.03'

local memcached = require "resty.memcached"

function connect(host,port,timeout)
    if not host or not port then
        ngx.log(ngx.ERR,"Must supply a hostname and a port for memcache")
        return nil
    end

    local memcache, err = memcached:new()
    if err then 
        ngx.log(ngx.ERR,"Unable to instantiate resty.memcached") 
        return nil
    end
    
    memcache:set_timeout(timeout or 1000)

    local ok, err = memcache:connect(host,port)
    if not ok then
        ngx.log(ngx.WARN,"Unable to connect to memcache: " .. err)
        return nil
    end
    return memcache
end

function close(memcache)
    local ok,err = memcache:set_keepalive()
    if not ok then
        ngx.log(ngx.WARN, "Unable to set keepalive: " .. err)
    end
end

-- Connects, retrieves a key and then disconnects (setkeepalives) from memcache
function get(host,port,key)
    local memcache = connect(host,port)
    -- If we couldn't get a memcache connection, then just return nothing
    -- - connect produces its own error messages.
    if not memcache then
        return nil
    end

    if not key then
        ngx.log(ngx.INFO,'No memcache key given')
        return nil
    end

    -- Attempt to retrieve the session from memcache then setkeepalive
    local res,flags,err = memcache:get(key)
    close(memcache)

    if err then
        ngx.log(ngx.ERR,string.format(
            "Unable to get key '%s' from memcache: %s",key,err))
        return nil
    end

    if not res then
        ngx.log(ngx.INFO,string.format("Key '%s' not found",key))
        return nil
    end

    return res
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}
setmetatable(_M, class_mt)

