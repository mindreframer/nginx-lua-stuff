#!/usr/bin/env lua

module("id",package.seeall)

--
local resty_uuid = require("resty.uuid")

--return uuid to 
function getid(req,resp)
	local id8 = resty_uuid:gen8()
	local id20 = resty_uuid:gen20()	
	--ngx.say(id8)
	--ngx.say(id20)
	--ngx.exit(200)
	resp:outJson(200,id8..'  '..id20)
	--resp:outStream(200,id8..'    '..id20)
end
