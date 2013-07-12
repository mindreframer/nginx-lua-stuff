#!/usr/bin/env lua


module('yagami.vars', package.seeall)

require 'yagami.functional'

function _setup()
    local ygm_global={}
    
    local function _set(app_name,k,v)
        if not ygm_global[app_name] then
            ygm_global[app_name]={}
        end
        ygm_global[app_name][k]=v
        return v
    end
    
    local function _get(app_name, k)
        if not ygm_global[app_name] then
            ygm_global[app_name]={}
        end
        return ygm_global[app_name][k]
    end

    local function _vars(app_name)
        if not ygm_global[app_name] then
            ygm_global[app_name]={}
        end
        return ygm_global[app_name]
    end
   
    return _set, _get, _vars
end

set, get, vars = _setup()


function make_table_perapp(tbl)
    if type(tbl) ~= "table" then return end
    
    local function _perapp_data(t)
        local data = rawget(t, ngx.ctx.YAGAMI_APP_NAME)
        if not data then
            data = {}
            rawset(t, ngx.ctx.YAGAMI_APP_NAME, data)
        end
        return data
    end
            
    local function _get(t, k)
        local data = _perapp_data(t)
        if k == "__table" then return data end
        return data[k]
    end

    local function _set(t, k, v)
        local data = _perapp_data(t)
        data[k]=v
    end

    setmetatable(tbl, {__index = _get, __newindex = _set})
end

function clear_table_perapp(tbl)
    if type(tbl) ~= "table" then return end
    rawset(tbl, ngx.ctx.YAGAMI_APP_NAME, {})
end

function apairs(tbl)
    if type(tbl) ~= "table" then return end
    if tbl.__table then return pairs(tbl.__table) end
    return pairs(tbl)
end
