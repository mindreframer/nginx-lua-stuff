--- Internal helpers for resty
-- @module resty.riak.helpers

local pairs = pairs
local ipairs = ipairs
local insert = table.insert

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


-- helper functions
function _M.table_to_RpbPairs(t)
    local rc
    if t then
	rc = {}
	for k,v in pairs(t) do
	    insert(rc, { key = k, value = v})
	end
	return rc
    else
	return nil
    end
end

function _M.RpbPairs_to_table(p)
    local t = {}
    if p then
        for _,m in ipairs(p) do
            t[m.key] = m.value
        end
    end
    return t
end


return _M