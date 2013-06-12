local setmetatable = setmetatable
local string = string
local error = error
local ngx = ngx
module(...)

_VERSION = '0.02'

function get_cookie(cookie)
    return ngx.var['cookie_' .. cookie]
end

function append_via_header(identifier)
    local via = string.format('1.1 %s (%s)',ngx.var.server_name,identifier)
    ngx.header['Via'] = (ngx.header['Via'] ~= nil) and (via .. ', ' .. 
        res.header['Via']) or via
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}
setmetatable(_M, class_mt)
