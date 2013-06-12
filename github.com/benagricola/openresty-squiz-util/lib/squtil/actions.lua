local setmetatable = setmetatable
local error = error
local require = require
local ngx = ngx
module(...)

_VERSION = '0.04'

local url = require "squtil.url"

-- Flips the scheme of an nginx request 
function redirect_flip_scheme()
    return ngx.redirect(url.full((ngx.var.scheme == 'http') 
        and 'https' or 'http'),ngx.HTTP_MOVED_TEMPORARILY)
end

-- Redirects to a different path. If append is true,
-- then appends the given path to the current ngx.var.uri
-- otherwise simply redirects to the given path.
function redirect_path(path,append)
    if append then
        local path = url.relative(ngx.var.uri .. path)
    end

    return ngx.redirect(path,ngx.HTTP_MOVED_TEMPORARILY)
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}
setmetatable(_M, class_mt)
