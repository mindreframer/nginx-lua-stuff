module("ssga", package.seeall)

math.randomseed (ngx.now())
ssga = {}

function ssga.new(ua, domain, options) 
	local self = {}

	local ga_host = 'www.google-analytics.com'
	local ga_ssl_host = 'ssl.google-analytics.com'
	local ga_url = '/__utm.gif'
	local port = 80;
	local user_agent = "ngnix-lua server side analytics/0.1"
	local language = "it"
	local options = {}

	-- as seen on 
	-- https://developers.google.com/analytics/resources/articles/gaTrackingTroubleshooting#gifParameters
	local data = {
		utmac = nil, 
		utmcc = nil, 
		utmcn = nil,
		utmcr = nil,
		utmcs = nil,
		utmdt = '-',
		utmfl = '-',
		utmip = nil,
		utme = nil,
		utmhn = nil,
		utmipc = nil,
		utmipn = nil,
		utmipr = nil,
		utmiqt = nil,
		utmiva = nil,
		utmje = 0,
		utmn = nil,
		utmp = nil,
		utmr = nil,
		utmsc = '-',
		utmsr = '-',
		utmt = nil,
		utmtci = nil,
		utmtco = nil,
		utmtid = nil,
		utmtrg = nil,
		utmtsp = nil,
		utmtst = nil,
		utmtto = nil,
		utmttx = nil,
		utmul = '-',
		utmwv = '5.2.5' 
	}
	local tracking_url = ""

	local function create_req_url()
		return tostring(ga_url .. '?' .. ngx.encode_args(data))
	end

	local function create_cookie() 
		local rand_id = math.random( 10000000, 99999999 )
		local random = math.random( 1000000000, 2147483647 )
		local var = '-'
		local time = ngx.now()
		local cookie = '__utma='  .. rand_id .. '.' .. random .. '.' .. time .. '.' .. time .. '.' .. time .. '.2;+'
			cookie = cookie .. '__utmb=' .. rand_id .. ';+'
			cookie = cookie .. '__utmc=' .. rand_id .. ';+'
			cookie = cookie .. '__utmz=' .. rand_id .. '.' .. time .. '.2.2.utmccn=(direct)|utmcsr=(direct)|utmcmd=(none);+'
			cookie = cookie .. '__utmv=' .. rand_id .. '.' .. var .. ';'

		return cookie
	end

	local function set_options(o) 
		
		-- compute user-agent string
		if(o and o.user_agent) then 
			options.user_agent = o.user_agent 
		else 
			if ngx.req.get_headers()["User-Agent"] then
				options.user_agent = ngx.req.get_headers()["User-Agent"]
			else
				options.user_agent = user_agent 
			end
		end

		-- prefix for request URL
		if(o and o.prefix) then options.prefix = o.prefix else options.prefix = '' end

		-- set language of request
		if(o and o.language) then 
			options.language = o.language
		else 
			if ngx.req.get_headers()["Accept-Language"] then
				options.language = ngx.req.get_headers()["Accept-Language"]
			else
				options.language = language 
			end
		end

		ngx.say("user_agent: ", options.user_agent)
		ngx.say("prefix: ", options.prefix)
		ngx.say("language: ", options.language)

	end


	function self.set_page(self, page, prefix) 
		page = prefix and prefix:gsub("/$", "") .. "/" .. page:gsub("^/", "") or page
		data['utmp'] = page
		return self
	end

	function self.send(self) 
		tracking_url = create_req_url()
        ngx.log(ngx.DEBUG, "tracking url: ", tracking_url)

        local host = ga_host;

        -- TODO: SSL support
        --if("https" == ngx.var.scheme) then 
        --	host = ga_ssl_host
        --	port = 443
        --end


		local sock = ngx.socket.tcp()
        local ok, err = sock:connect(host, port)
        if not ok then
            ngx.log(ngx.ERR, "failed to connect to google analytics: ", err)
            return
        end

        local request = "GET " .. tracking_url .. " HTTP/1.1\n"
       	request = request .. "Host: " .. host .. "\n" 
        request = request .. "Referer: " .. data['utmr'] .. "\n" 
        request = request .. "User-Agent: " .. options.user_agent .. "\n" 
        request = request .. "Accept-Language: " .. options.language .. "\n" 
        request = request .. "\n\n"


        sock:settimeout(1000)
		local bytes, err = sock:send(request)		
        if not bytes then
            ngx.log(ngx.ERR, "failed to send data to google analytics: ", err)
            return
        end

        ngx.log(ngx.DEBUG, "successfully connected to google analytics!")
        sock:close()		
	end

	data['utmac'] = ua
	data['utmhn'] = domain
	data['utmp'] = ngx.var.uri
	data['utmn'] = math.random(1000000000, 9999999999)	
	data['utmr'] = ngx.req.get_headers()["Referer"] and ngx.req.get_headers()["Referer"] or ''
	data['utmcc'] = create_cookie()

	-- if request passed through a proxy (very common in ngnix configurations)
	if(ngx.req.get_headers()["X-Real-IP"] or ngx.req.get_headers()["X-Forwarded-For"]) then
		data['utmip'] = ngx.req.get_headers()["X-Real-IP"] and ngx.req.get_headers()["X-Real-IP"] or ngx.req.get_headers()["X-Forwarded-For"]
	else
		data['utmip'] = ngx.var.remote_addr
	end

	set_options(options)

	return self
end

function track(options)

	-- check and fix mandatory params
	if(not (options and options.ua)) then 
		ngx.log(ngx.ERR, "you must specify UA code to track visits")
		return
	end
	options.domain = options.domain and options.domain or ngx.var.host
	options.page = options.page and options.page or ngx.var.uri
	options.prefix = options.prefix and options.prefix or ''

	-- to track the real ip address of the visitor we use the utmip param, but it seems to
	-- work only in "mobile mode".So we change the UA ID to a mobile one, just by replacing	
	-- the UA part with MO
	local ssga = ssga.new(options.ua:gsub('UA', 'MO'), options.domain, options) 
	ssga:set_page(options.page, options.prefix)
	
	ssga:send()
end
