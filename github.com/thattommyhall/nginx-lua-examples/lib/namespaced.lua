local memcached = require "resty.memcached"
local uri = ngx.var.uri
local host = ngx.var.host

local function identity(s)
   return s
end

local memc, err = memcached:new{ key_transform = { identity, identity } }
if not memc then
   ngx.log(ngx.ERR,"could not create memcache object")
   ngx.exit(404)
   return
end

memc:set_timeout(250)

local ok, err = memc:connect("127.0.0.1", 11211)
if not ok then
   ngx.log(ngx.ERR,"failed to connect: ", err)
   ngx.exit(404)
   return
end

sitename = host
prefix_key = "prefixfor:" .. sitename

local prefix, flags, err = memc:get(prefix_key)
if not prefix then
   ngx.log(ngx.ERR,"no prefix for " .. prefix_key)
   ngx.exit(404)
   return
end

page_key = prefix .. ':' .. uri
local page, flags, err = memc:get(page_key)
if not page then
   ngx.log(ngx.ERR,"no page for " .. page_key)
   ngx.exit(404)
   return
end

ok, err = memc:set_keepalive('30000',5)
ngx.print(page)
