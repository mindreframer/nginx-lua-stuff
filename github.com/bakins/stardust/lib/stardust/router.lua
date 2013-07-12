--- Ziggy Router
-- @module stardust.router
-- @alias _M

local insert = table.insert
local match = string.match
local lower = string.lower
local upper = string.upper
local request = require "stardust.request"

local _M = {}

local function call(self, req, res)
    local method = req.method
    local routes = self.routes
    local uri = req.uri
    for i=1,self.num_routes do
	local route = routes[i]
	local m = route.method
	if (not m) or m == method then
	    local rc = route.pattern(uri)
	    if rc then
		if type(rc) == "table" then
		    req.ctx.__params = rc
		else
		    req.ctx.__params = nil
		end
		-- should wrap in pcall??
		-- maybe wrap all middleware in pcall?
		return route.func(req, res)
	    end
	end
    end
end

request.register_index("params",
		       function(req)
			   return req.ctx.__params or {}
		       end
		      )

local mt = { __index = _M, __call = call }
--- Create a new stardust router.
-- @return a stardust router
function _M.new()
    local self = {
	routes = {
	},
	num_routes = 0
    }
    return setmetatable(self, mt)
end

function pack(...)
    if ... then
	return { n = select("#", ...), ... }
    else
	return nil
    end
end

-- is using __call slow???
local pattern_mt = {
    __tostring = function(self) return "pattern: " .. self.pattern end,
    __call = function(self, uri)
	local t = pack(match(uri, self.pattern))
	return (t and #t > 0) and t or nil
    end
}

--- Create a Lua string match match object for use with a route
-- @param self stardust router
-- @param pattern Lua string mattern
-- @return an object usable with a route
-- @usage
-- local r = stardust.router.new()
-- r:get(r:pattern("/foo/(%d+)"), function(req, res) ... end)
-- -- captures are availible in req.params
-- -- in above, the capture is availible in r.params[1]
function _M.pattern(self, pattern)
    return setmetatable({ pattern = pattern }, pattern_mt)
end

local exact_mt = {
    __tostring = function(self) return "exact: " .. self.pattern end,
    __call = function(self, uri)
	local uri = self.caseless and lower(uri) or uri
	return uri == self.pattern
    end
}

--- Create a exact match object for use with a route. This just checks if two strings are equal
-- @param self stardust router
-- @param pattern string to match
-- @param caseless whether to do casless match. defaults to false
-- @return an object usable with a route
function _M.exact(self, pattern, caseless)
    return setmetatable({ pattern = caseless and lower(pattern) or pattern, caseless = caseless }, exact_mt)
end

local regex_mt = {
    __tostring = function(self) return "regex: " .. self.pattern end,
    __call = function(self, uri)
	return ngx.re.match(uri, self.pattern, self.caseless and "io" or "o")
    end
}

--- Create a regex match object for use with a route
-- @param self stardust router
-- @param pattern regular expression
-- @param caseless whether to do casless match. defaults for false
-- @return an object usable with a route
-- @usage
-- local r = stardust.router.new()
-- r:get(r:regex("/foo/([0-9]+)"), function(req, res) ... end)
-- -- captures are availible in req.params
-- -- in above, the capture is availible in r.params[1]
-- -- you can also used named captures
-- r:get(r:regex("/foo/(?<id>[0-9]+)"), function(req, res) ... end)
-- -- capture is availible as r.params[1] as well as r.params.id
function _M.regex(self, pattern, caseless)
    return setmetatable({ pattern = pattern, caseless = caseless }, regex_mt)
end

--- Add a route
-- @tparam stardust.router self
-- @param method HTTP method, ie GET, POST. If nil, this will apply to all methods
-- @param pattern uri pattern to match. if this is a string, it is used as a Lua string pattern. Use the results from exact, regex, pattern ,etc
-- @param func function to call when this pattern is matched. function should take 2 arguments: `stardust.request` and `stardust.response` and return nothing on success
-- @treturn stardust.router self
-- @usage app = stardust.new()
--app:route('GET', '/foo', function(ngx, res) res.body = "hello" end)

function _M.route(self, method, pattern, func)
    if type(pattern) == "string" then
	pattern = _M.pattern(self, pattern)
    end
    method = method and upper(method)
    insert(self.routes, { method=method, pattern = pattern, func = func })
    self.num_routes = self.num_routes + 1
    return self
end

local route = _M.route

-- be explicit for documentation...

--- Convenience function to add a route for GET
-- @param self stardust application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.get(self, pattern, func)
    return route(self, "GET", pattern, func)
end

--- Convenience function to add a route for POST
-- @param self stardust application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.post(self, pattern, func)
    return route(self, "POST", pattern, func)
end

--- Convenience function to add a route for PUT
-- @param self stardust application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.put(self, pattern, func)
    return route(self, "PUT", pattern, func)
end

--- Convenience function to add a route for DELETE
-- @param self stardust application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.delete(self, pattern, func)
    return route(self, "DELETE", pattern, func)
end

--- Convenience function to add a route that matches all http methods
-- @param self stardust application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.all(self, pattern, func)
    return route(self, nil, pattern, func)
end

return _M