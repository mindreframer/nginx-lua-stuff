-- very simple redis HTTP api

local stardust = require "stardust"
local router = require "stardust.router"
local redis = require "resty.redis"
local cjson = require "cjson"
local encode = cjson.encode
local insert = table.insert

local gmatch = string.gmatch

local _M = {}

local app = stardust.new()
local r = router.new()
app:use(r)

local function json(res, data)
    res.status = 200
    res.headers["Content-Type"] = "application/json"
    res.body = encode(data)
    return res
end

local function redis_wrapper(req, res)
    local t = {}
    for word in gmatch(req.path, "([^/]*)") do
	if #word > 0 then
	    insert(t, word)
	end
    end
    local cmd = t[1]
    local args = {}

    for i=2, #t do
	args[i-1] = t[i]
    end
    
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
	ngx.say("failed to connect: ", err)
	return
    end

    local results, err = redis[cmd](red, unpack(args))

    if not results then
	ngx.say("failed: " .. cmd .. ": " .. err)
	red:close()
	return
    end

    red:set_keepalive(0, 100)
    json(res, { command = cmd, args = args, results = results })
end

r:get("/", redis_wrapper)

function _M.run(ngx)
    return app:run(ngx)
end

return _M