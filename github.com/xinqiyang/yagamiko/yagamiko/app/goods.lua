#!/usr/bin/env lua

--
-- goods moudle
--

module("goods",package.seeall)


local JSON = require("cjson")


-- do set goods reset 
-- set to hmset
function bootstrap(req,resp)
	logger:i("start goods")
	local ok = 404
	local err = "System error"
	if req.method == 'POST' then 
		ok,err = post(req)
	elseif req.method == 'GET' then
		ok,err = get(req)
	elseif req.method == 'PUT'  then 
		ok,err = put(req)
	elseif req.method == 'DELETE' then	
		ok,err = delete(req)
	end
	ngx.status = ok
	resp.headers['Content-Type'] = 'application/json'
    resp:writeln(JSON.encode(err))
end


function get(req)

	ngx.say('this is good get')


	return 200,"GET OK"
end 


function post(req)

    ngx.say('this is good post ')


	return 200,"POST OK"
end


function put(req)





	return 200,"PUT OK"
end


function delete(req) 





	return 200,"DELETE OK"
end


