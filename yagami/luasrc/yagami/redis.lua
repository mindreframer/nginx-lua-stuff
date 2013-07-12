#!/usr/bin/env lua

module("yagami.redis",package.seeall)

local util = require("yagami.util")
local Redis = require("resty.redis")

--set default set of redis
local defaultSet = "redis_set01"
local redis_pool_size = 100


-- add a new redis cluster instance 
function redis_master(set)
    local client = Redis:new()
    if not client then
        return nil
    end

    -- set default cluster 
    if set ==nil or util.isNotEmptyString(set) == false then 
    	set = defaultSet
    end

   	local t_set = util.get_config(set)
    client:set_timeout(tonumber(t_set.timeout)) -- 3 seconds
    local ok, err = client:connect(t_set.master,tonumber(t_set.masterport))
    if not ok then
    	logger.e("Redis Master is down: "..host..':'..port)
        return nil
    end
    return client
end

-- add a slave instance 
-- use slave by random set , @TODO add other slave and support retry setting
function redis_slave(set)
    local client = Redis:new()
    if not client then
        return nil
    end
    
    -- set default cluster 
    if set == nil or util.isNotEmptyString(set) == false then
    	set = defaultSet
    end
   
    local t_set = util.get_config(set)
    client:set_timeout(tonumber(t_set.timeout)) -- 3 seconds

    local host,port = util.splitSlave(t_set.slave)
    local ok, err = client:connect(host, tonumber(port))
    
    if not ok then
    	-- log error 
    	logger.e("Redis Slave is down: "..host..':'..port)
        return nil
    end
    return client
end


