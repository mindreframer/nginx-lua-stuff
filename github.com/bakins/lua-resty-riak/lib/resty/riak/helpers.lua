--- Internal helpers for resty
-- @module resty.riak.helpers

local _M = {}

-- based on strict.lua and agentzh's lua-resty-*

local getinfo = debug.getinfo

local function what ()
    local d = getinfo(3, "S")
    return d and d.what or "C"
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function(table, key, val)
	local w = what()
		     if w ~= "main" and w ~= "C" then
			 error('attempt to write to undeclared variable "' .. key .. '"')
		     end
		     rawset(table, key, val)
    end
}

--- create a "module". This sets up metatable to avoid using undeclared globals, etc
-- @treturn table the module
function _M.module()
    local _M = {}
    setfenv(2, _M)
    return setmetatable(_M, class_mt)
end

return _M