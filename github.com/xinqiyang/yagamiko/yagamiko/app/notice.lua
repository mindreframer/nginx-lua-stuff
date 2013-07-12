#!/usr/bin/env lua

--
-- brand moudle
--

module("notice",package.seeall)


local JSON = require("cjson")


-- do set goods reset 
-- set to hmset
function bootstrap(req,resp)
	local ok = 500
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



	return 200,"GET OK"
end 


function post(req)




	return 200,"POST OK"
end


function put(req)





	return 200,"PUT OK"
end


function delete(req) 





	return 200,"DELETE OK"
end


