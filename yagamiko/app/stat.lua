#!/usr/bin/env lua

module("stat",package.seeall)

local util = require('ygmutils')

--count service 
function countService(funcname)
	-- body
	local k = "count:";
	
	local red = Redis:new()
	local ok, err = red:connect("127.0.0.1", 6379)

	if not ok then
		logger:i({"failed to connect: ", err})
	end

	local day = os.date("%Y%m%d",time);
	local hour = os.date("%Y%m%d%H",time);

	-- lua
	Field = {
		[1] = 'total',
		[2] = day,
		[3] = hour,
	}

	for key,val in ipairs(Field) do
		local ck = k..funcname..":"..val
		--logger:i("countserver key:  "..ck.."\n")
		red:incrby(ck,1)
	end

end

	



