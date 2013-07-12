local upper = string.upper
local stardust = require "stardust"
local router = require "stardust.router"

local _M = {}

-- stupid simple middleware that just uppercases response

local function middleware(req, res)
    res.body = upper(res.body)
end

local app = stardust.new()
local r = router.new()
app:use(r)
app:use(middleware)
app:use(stardust.sender)

r:get("/",
      function(req, res)
	  res.body = req.path .. "\n"
      end
     )

function _M.run(ngx)
    return app:run(ngx)
end


return _M
