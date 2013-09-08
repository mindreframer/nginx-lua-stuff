local bandit = require 'bandit'
local common = require 'common'

local args = ngx.req.get_uri_args()
local key = args['c'] .. ":click:" .. args['b']
local total_key = args['c'] .. ":click:total"

ngx.log(ngx.NOTICE, "key -> " .. key)

common.increment_key(ngx.shared.beacons, key)
common.increment_key(ngx.shared.beacons, total_key)

bandit.update(args['b'], 1)
