--- Ziggy Request
-- @module stardust.request
-- @alias _M


-- wraps an nginx request
-- copy something like http://expressjs.com/api.html#req.params ?
-- or something "rack-like"
-- I prefer my method of doing responses, however

local lower = string.lower
local gsub = string.gsub

local _M = {}

-- normal index functions get a "request" object
local index_funcs = {
}

--- Register a new "field" that can be used on a request object.
-- @param key the field name
-- @param func function to call when the field is access. The function should take a single argument, the request
-- @usage Example:
--stardust.request.register_raw_index("foo", function(req) return string.upper(req.header["User-Agent"]) end)
--req.foo -- will the user-agent uppercased
function _M.register_index(key, func)
    index_funcs[key] = func
end

local register_index =  _M.register_index

register_index("method", function(req) return req.ngx.req.get_method() end)

local simple_indexes = {
    query = "args",
    args = "args",
    -- should provide a parse mechanism for cookies??
    cookies = "http_cookies",
    ip = "remote_addr",
    path = "uri",
    uri = "uri",
    host = "host",
    user_agent = "http_user_agent"
}

for k,v in pairs(simple_indexes) do
    register_index(k, function(req) return req.ngx.var[v] end)
end

register_index("headers", function(req)
		   local headers = req.ctx.__headers
		   if not headers then
		       headers = ngx.req.get_headers()
		       req.ctx.__headers = headers
		   end
		   return headers
			  end
	      )

local function index_function(t, k)
    local func = rawget(index_funcs, k)
    if func then
	return func(t, k)
    end
    local ngx = rawget(t, ngx)
    -- try to see if it's an http value
    local val = ngx.var["http_" .. gsub(lower(k), "-", "_")]
    if val then
	return val
    end
    -- is it just a normal var?
    val = ngx.var[lower(k)]
    if val then
	return val
    end

    return nil
end

local function newindex_function(t, key, val)
    -- this should probably throw an error??
end

--- Create a new request object.
-- A response object a table with some helper functions. You generally only access it via the helper functions
-- or the magic of its metatable
-- @param ngx magic nginx lua object
-- @return a response object
function _M.new(ngx)
    local self = {
	ngx = ngx,
	ctx = {}
    }
    return setmetatable(self, { __index = index_function, __newindex = newindex_function })
end

--- Request object can be access like a table.
-- @field path path portion of the url
-- @field query query string
-- @field cookies raw cookie header
-- @field ip client remote address
-- @field host HTTP host header or the virtual server name
-- @field headers table like container of http request headers. req.headers["User-Agent"]. Note: consider this read only. Any changes here will be ignored.
-- @field ctx a Lua table that can be used as scratch space. No effort is made to avoid collisions, so namespace your keys.
-- @table request


return _M