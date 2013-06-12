local setmetatable = setmetatable
local error = error
local ngx = ngx
module(...)

_VERSION = '0.02'

-- Return the current relative URL, optionally overriding each part of it 
-- (uri,query_string). Items which do not need to be overridden can be called
-- with nil.
function relative(uri,query_string)
    return (uri or ngx.var.uri) .. (query_string and '?' or ngx.var.is_args)
    	.. (query_string or ngx.var.query_string or "")
end

-- Return the current full URL, optionally overriding each part of it 
-- (scheme,host,uri,query_string). Items which do not need to be 
-- overridden can be called with nil.
function full(scheme,host,...)
    return (scheme or ngx.var.scheme) .. '://' .. (host or ngx.var.host)
    	.. relative(...)
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}
setmetatable(_M, class_mt)
