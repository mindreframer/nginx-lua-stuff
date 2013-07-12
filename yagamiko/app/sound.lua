#!/usr/bin/env lua


module("sound", package.seeall)

local JSON = require("cjson")
local Redis = require("resty.redis")
local md5 = require("resty.md5")
local http = require("resty.http")

function soundget( req,resp )
	req:read_body()
	resp.headers['Content-Type'] = 'application/octet-stream'

	local ret = "ERROR"
	local newsid = ""
	local validate = false

	if req.method=='POST' then
		if(req.post_args['newsid']) then
			--construct data
			--logger:i(tostring(req.post_args));

			local json = req.post_args['newsid']
			--if(json) {
			--   local jsondecode = JSON:decode(json)
			--   if(jsondecode["newsid"]) {
			--      newsid = jsondecode["newsid"]
			--      validate = true
			--   }
			--}
			newsid = req.post_args['newsid']
			validate = true
			ret = "OK"
		else
			ret ="ParamsError"
		end
	end

	if(validate == true) then
		local red = Redis:new()
		local ok, err = red:connect("127.0.0.1", 6379)
		if not ok then
			logger:i({"failed to connect: ", err})
		end
		local k = "sound:"..newsid   --  "foo"..tostring(i)
		local v = red:get(k)
		logger:i("k :"..tostring(k))

		if tostring(v) == "userdata: NULL" then
			logger:i("return:204")
			ngx.exit(204)
		else
			logger:i("return value")
			-- write the stream
			resp:write(v)
		end
	else
		ngx.exit(400)
	end

	resp:finish()

	--count service
	countService("soundget")

end


--set sound make
function soundmake( req,resp )
	-- body
	-- get params
	req:read_body()
	resp.headers['Content-Type'] = 'application/octet-stream'

	local ret = "ERROR"

	local newsid = ""
	local newscontent = ""
	local lang = ""
	local newsinfo = {}

	local validate = false

	if req.method=='POST' then
		if(req.post_args['newsid'] and req.post_args['newscontext'] and req.post_args['language'] and req.post_args['postdate']) then
			--construct data
			newsid = urldecode(req.post_args['newsid'])
			-- url encode
			newscontent = urldecode(req.post_args['newscontext'])

			newsinfo['newsid'] = newsid
			newsinfo['newscontent'] = newscontent
			lang = urldecode(req.post_args['language'])
			newsinfo['language'] = lang
			newsinfo['postdate'] = urldecode(req.post_args['postdate'])

			logger:i("--start-------------------\n"..tostring(newsid).."\n  "..tostring(newscontent).."\n   "..tostring(lang).."\n   "..tostring(newsinfo['postdate']).."\n")

			if newscontent and lang then
				validate = true
			end
			ret = "OK"
		else
			ret ="ParamsError"
		end
	end

	if(validate == true) then

		-- request the url
		-- change to post
		local apiurl = "http://192.168.1.20/sound.php"


		--local apiurl = "http://192.168.1.20/sound.php?text="..urlencode(newscontent).."&lang="..lang.."&newsid="..newsid
		--logger:i("url:"..apiurl.."\n")
		local hc = http:new()
		--logger:i("body:".."newsid="..urlencode(newsid).."&text="..urlencode(newscontent).."&lang="..urlencode(lang));
		-- request get then get the output from api
		local ok,code,headers,status,body = hc:request {
			url = apiurl,
			method = "POST",
			timeout = 160000,
			headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
			body = "newsid="..urlencode(newsid).."&text="..urlencode(newscontent).."&lang="..urlencode(lang),
		}

		if code == 200 then
			logger:i("---------request php ok output stream--------\n")
			-- write the stream
			resp:write(body)
			resp:finish()


			local red = Redis:new()
			local ok, err = red:connect("127.0.0.1", 6379)
			if not ok then
				logger:i({"failed to connect: ", err})
			end

			local k = "sound:"..newsid
			red:set(k,body)

			logger:i("----save to redis key:"..k)

			-- save client info to redis
			local kinfo = "info:"..newsid
			red:hmset(kinfo,newsinfo)

			-- save time
			local s = newsinfo['postdate']
			local p="%a+, (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) GMT"
			local runday, runmonth, runyear, runhour, runminute, runseconds = s:match(p)
			local MON={Jan=01,Feb=02,Mar=03,Apr=04,May=05,Jun=06,Jul=07,Aug=08,Sep=09,Oct=10,Nov=11,Dec=12}
			local nowmonth = MON[runmonth]

			local pubdate = runyear..nowmonth..runday
			-- add time and newsid to list
			local cacheKey = "list:news:"..pubdate
			logger:i("news info cache key: "..cacheKey.."   "..newsid)
			red:lpush(cacheKey,newsid)
			--count the service
			countService("soundmake")

		else
			logger:i("---request php error---"..tostring(newsid).."  "..tostring(code))
			--if sound service error then return 404
			ngx.exit(404)
		end
		logger:i("----------request end --"..tostring(newsid))
	end

	--request the out info



end

--set count service
function countService( funcname )
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

-- @TODO: 
function userstat()
--get request info from request
--ngx.req.get_headers()['X-GNBinder-security']

end


function urlencode(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end


function urldecode(str)
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)",
	function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end
