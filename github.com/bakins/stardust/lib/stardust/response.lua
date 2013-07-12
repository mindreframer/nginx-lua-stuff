--- Ziggy Response
-- @module stardust.response
-- @alias _M

local len = string.len

local _M = {}

local mt = { __index = _M }
--- Create a new response object.
-- A response object is just a table with some helper functions.
-- @param ngx magic nginx lua object
-- @return a response object/table
-- @usage You can directly manipulate the reponse object fields: 
-- * status - should be an http code as an integer
-- * headers - a table of http response headers
-- * body - a string of the http response
-- * ctx - a Lua table that can be used as scratch space. No effort is made to avoid collisions, so namespace your keys.
function _M.new(ngx)
    local self = {
	ngx = ngx,
	status = 200,
	headers = {},
	body = nil,
	ctx = {}
    }
    return setmetatable(self, mt)
end

--- Send the repsonse to the client
-- You should call this only once
-- @tparam stardust.response self
function _M.send(self)
    -- do we need to check if we have send the response yet or not?
    local ngx = self.ngx
    -- to ensure keepalives, etc work correctly
    ngx.req.discard_body()
    local headers = self.headers or {}
    local status = tonumber(self.status) or 500

    if status < 500 then
        local content_type = headers["Content-Type"]
        if not content_type then
            headers["Content-Type"] = "text/plain"
        end
        local body = self.body or ""
	if type(body) == "string" then
	    headers["Content-Length"] = len(body)
	end
        ngx.status = status
        for k,v in pairs(headers) do
            ngx.header[k] = v
        end
        ngx.print(body)
        ngx.eof()
    else
        return ngx.exit(status)
    end
end

return _M