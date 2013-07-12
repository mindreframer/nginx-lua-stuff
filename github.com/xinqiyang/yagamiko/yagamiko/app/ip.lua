#!/usr/bin/env lua

module("ip", package.seeall)

--local JSON = require("cjson")
--local Redis = require("resty.redis")

local qqwry = require("qqwry")
local util = require("yagami.util")

local  q = require("ipquery")

-- init the class 
	
function getip(req, resp)
	local ip = req.uri_args['ip'] 
	-- output header
	resp.headers['Content-Type'] = 'text/html'
	resp.headers['charset'] = 'utf-8'
	
	resp:writeln(qqwry.query(ip)[1])
	resp:writeln(qqwry.query(ip)[2])
	local t = qqwry.version()
	
	resp:writeln(table.concat(t))
	
end


function getipnew(req,resp)
	-- load once 
	local path = util.get_config("ip")
	q.load_data_file(path.ip)

	--
	local ip = req.uri_args['ip']
	if ip ==nil or util.isNotEmptyString(ip) == false then 
		ngx.status = 400
	end
	
	local info = q.get_ip_info(ip)

	if info then 
		info = info
	else 
		info = 'null' 
	end
	resp.headers['Content-Type'] = 'text/plain'
	resp:writeln(info)
end
