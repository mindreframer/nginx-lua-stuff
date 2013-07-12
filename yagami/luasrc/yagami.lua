#!/usr/bin/env lua

--
-- Yagami Framework Core 
--
--


local string_match   = string.match
local package_loaded = package.loaded

ygm_vars = nil
ygm_debug = nil

-- parse gloable params
function is_inited(app_name, init)
    -- get/set the inited flag for app_name
    local r_G = _G
    local mt = getmetatable(_G)
    if mt then
        r_G = rawget(mt, "__index")
    end
    if not r_G['yagami_inited'] then
        r_G['yagami_inited'] = {}
    end
    if init == nil then
        return r_G['yagami_inited'][app_name]
    else
        r_G['yagami_inited'][app_name] = init
        if init then
            -- put logger into _G
            local logger = require("yagami.logger")
            r_G["logger"] = logger.logger()
        end
    end
end

--set app params
function setup_app()
    local ygm_home = ngx.var.YAGAMI_HOME or os.getenv("YAGAMI_HOME")
    local app_name = ngx.var.YAGAMI_APP_NAME
    local app_path = ngx.var.YAGAMI_APP_PATH
    local app_config = app_path .. "/application.lua"
	
	--ngx.log(ngx.ERR, 'setup app -----  app name:  '..ngx.var.YAGAMI_APP_NAME..'  app path:'..ngx.var.YAGAMI_APP_PATH..'   app config:'..app_config)
	--ngx.exit(200)
    
    
	
	package.path = ygm_home .. '/luasrc/?.lua;' .. package.path
    ygm_vars = require("yagami.vars")
    ygm_debug = require("yagami.debug")
    
    local ygm_util = require("yagami.util")
    -- setup vars and add to package.path
    ygm_util.setup_app_env(ygm_home, app_name, app_path,
                          ygm_vars.vars(app_name))

    local logger = require("yagami.logger")
        
    local config = ygm_util.loadvars(app_config)
    
    if not config then config={} end
    
    ygm_vars.set(app_name,"APP_CONFIG",config)
    
    is_inited(app_name, true)
    
    if type(config.subapps) == "table" then
        for k, t in pairs(config.subapps) do
            local subpath = t.path
            package.path = subpath .. '/app/?.lua;' .. package.path
            local env = setmetatable({__CURRENT_APP_NAME__ = k,
                                      __MAIN_APP_NAME__ = app_name,
                                      __LOGGER = logger.logger()},
                                     {__index = _G})
            setfenv(assert(loadfile(subpath .. "/routing.lua")), env)()
        end
    end

    -- load the main-app's routing
    local env = setmetatable({__CURRENT_APP_NAME__ = app_name,
                              __MAIN_APP_NAME__ = app_name,
                              __LOGGER = logger.logger()},
                             {__index = _G})
    --set routing                         
    setfenv(assert(loadfile(app_path .. "/routing.lua")), env)()
    
    -- merge routings
    yagami.router = require("yagami.router")
    yagami.router.merge_routings(app_name, config.subapps or {})

    -- debug open or stop
    if config.debug and config.debug.on and ygm_debug then
        debug.sethook(ygm_debug.debug_hook, "cr")
    end

end

-- start deal request
function content()
    local ngx_ctx = ngx.ctx
    
    ngx_ctx.YAGAMI_APP_NAME = ngx.var.YAGAMI_APP_NAME
    if (not is_inited(ngx_ctx.YAGAMI_APP_NAME)) or (not package_loaded["yagami.vars"]) then
        local ok, ret = pcall(setup_app)
        if not ok then
            local error_info = "YAGAMI APP SETUP ERROR: " .. ret
            ngx.status = 500
            ngx.say(error_info)
            ngx.log(ngx.ERR, error_info)
            return
        end
    else
        ygm_vars  = require("yagami.vars")
        ygm_debug = require("yagami.debug")
    end

    if not is_inited(ngx_ctx.YAGAMI_APP_NAME) then
        local error_info = 'Can not setup YAGAMI APP: ' .. ngx_ctx.YAGAMI_APP_NAME
        ngx.status = 501
        ngx.say(error_info)
        ngx.log(ngx.ERR, error_info)
        return
    end

    local yagami_app_name = ngx_ctx.YAGAMI_APP_NAME
   
    local uri         = ngx.var.REQUEST_URI
    
    
    local route_map   = ygm_vars.get(yagami_app_name, "ROUTE_INFO")['ROUTE_MAP']
    local route_order = ygm_vars.get(yagami_app_name, "ROUTE_INFO")['ROUTE_ORDER']
    local page_found  = false

    -- match order by definition order
    for _, k in ipairs(route_order) do
        local args = string_match(uri, k)
        if args then
            page_found = true
            local v = route_map[k]
            -- set request and response 
            local request  = ygm_vars.get(yagami_app_name, 'YAGAMI_MODULES')['request']
            local response = ygm_vars.get(yagami_app_name, 'YAGAMI_MODULES')['response']

            local requ = request.Request:new()
            local resp = response.Response:new()
            ngx_ctx.request  = requ
            ngx_ctx.response = resp
            -- set return 
            if type(v) == "function" then                
                if ygm_debug then ygm_debug.debug_clear() end
                local ok, ret = pcall(v, requ, resp, args)
                if not ok then resp:error(ret) end
                resp:finish()
                resp:do_defers()
                resp:do_last_func()
            elseif type(v) == "table" then
                v:_handler(requ, resp, args)
            else
                ngx.exit(500)
            end
            break
        end
    end

    if not page_found then
        ngx.exit(404)
    end
end

-- boot
----------
content()
----------

