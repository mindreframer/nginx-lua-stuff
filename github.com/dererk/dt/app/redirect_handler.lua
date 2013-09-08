-- param definitions
local uri = ngx.var.uri

-- initialize redis
local redis = require 'redis'
local red = redis:new()
red:set_timeout(100)  -- in miliseconds  

local ok, err = red:connect('127.0.0.1', 6379)
if not ok then
    ngx.log(ngx.ERR, 'failed to connect: ', err)
    return
end

-- uri includes slash, stripping it cleans loads of code
uri = string.sub(uri,2)

local res, err = red:hget(uri, 'host')
if not res then
    ngx.log(ngx.ERR, 'failed to get: ', res, err)
    return
end

if  res == ngx.null or type(res) == null then
    ngx.log(ngx.ERR, 'failed to get redirection for key: ', uri)
    return ngx.redirect('https://duckduckgo.com/?q=What+Are+You+Looking+For?', ngx.HTTP_MOVED_TEMPORARILY)
else
    red:hincrby(uri, 'requested', 1)
    red:hset(uri, 'atime', os.time()) 
    ngx.log(ngx.ERR, 'Redirecting to: ', res)
    ngx.header['X-Redirect-ctime'] = red:hget(uri, 'ctime')
    return ngx.redirect(res, ngx.HTTP_MOVED_PERMANENTLY)
end
