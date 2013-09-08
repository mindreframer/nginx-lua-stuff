-- helpers definitions
--
local random        = math.random
local utils         = require 'utils'

-- parse body
--
ngx.req.read_body()

-- static definitions
--
local uri           = ngx.var.uri
local redirHost     = ngx.req.get_post_args(1)['host']

-- Init random seed
local key           = utils.baseEncode(random(56800235584))
local keyEdit       = utils.baseEncode(random(989989961727)) -- higher trigers interval is empty at 'random' 



-- initialize redis
--
local redis         = require 'redis'
local red           = redis:new()
red:set_timeout(100)  -- in miliseconds

local ok, err = red:connect('127.0.0.1', 6379)
if not ok then
    ngx.log(ngx.ERR, 'failed to connect: ', err)
    return
end

-- parse POST body
--
ngx.header.content_type = 'text/html';

if redirHost == null or 
   redirHost == ngx.null or
   string.find(string.lower(redirHost), '^https?://') == nil then

   -- It's not a HTTP Resource, die now biatch
   ngx.status = ngx.HTTP_GONE
   ngx.say(redirHost, ': You provided an invalid redirection (target is not a hypertext resource).')
   ngx.log(ngx.ERR, 'Resource was not a HTTP link (http nor https). Resource provided: ', redirHost)
   ngx.exit(ngx.HTTP_OK)
end

ok, err = red:hmset(key, 'host', redirHost, 'keyEdit', keyEdit, 'ctime', os.time(), 'ip', ngx.var.remote_addr, 'orig_headers', utils.tabletostr(ngx.req.get_headers()))
if not ok then
    ngx.say('failed to storage candidate redirection hash: ', err)
    return
else
    return ngx.redirect(utils.buildURL(ngx.var.base_url, key, 'view', keyEdit), ngx.HTTP_MOVED_TEMPORARILY)
end
