--
-- Lua script for interface Tirex engine
--
--
-- Copyright (C) 2013, Hiroshi Miura
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Affero General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Affero General Public License for more details.
--
--    You should have received a copy of the GNU Affero General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

local shmem = ngx.shared.osm_tirex

local udp = ngx.socket.udp
local time = ngx.time
local timerat = ngx.timer.at
local sleep = ngx.sleep

local sub = string.sub
local len = string.len
local find = string.find
local gmatch = string.gmatch
local format = string.format

local pairs = pairs
local unpack = unpack
local tonumber = tonumber
local tostring = tostring
local error = error
local assert = assert
local setmetatable = setmetatable

local osm_tile = require 'osm.tile'

module(...)

_VERSION = '0.30'

local tirexsock = 'unix:/var/run/tirex/master.sock'
local tirex_cmd_max_size = 512

-- ------------------------------------
-- Syncronize thread functions
--
--   thread(1)
--       get_handle(key)
--       do work
--       store work result somewhere
--       send_signal(key)
--       return result
--
--   thread(2)
--       get_handle(key) fails then
--       wait_singal(key, timeout)
--       return result what thread(1) done
--
--   to syncronize amoung nginx threads
--   we use ngx.shared.DICT interface.
--   
--   Here we use ngx.shared.osm_tirex
--   you need to set /etc/conf.d/lua.conf
--      ngx_shared_dict osm_tirex 10m; 

--   status definitions
--    key is not exist: no job exist for its x/y/z
--    key is exist: job exist
--
--       key := <map>:<x>:<y>:<zoom>
--       val := <req> | <result>
--       flag := <status>
--
--       <x>, <y>, <zoom> := <integer>
--       <req> := string: request command string
--       <result> := string: result string
--       <status> := <gothandle> | <request> | <send> | <succeeded> | <failed>
--
--    key will be expired in timeout(sec)
--
-- ------------------------------------
local GOTHANDLE =   0
local REQUEST   = 100
local SEND      = 200
local SUCCEEDED = 300
local FAILED    = 400
local SPECIAL   = 999

-- function: send_signal
-- argument: string key
--           number timeout in sec
--           number flag to send
-- return nil when failed
local function send_signal(key, timeout, flag)
    local ok, err = shmem:set(key, 0, timeout, flag)
    if not ok then
        return nil
    end
    return true 
end

local function round(num, idp)
  return tonumber(format("%." .. (idp or 0) .. "f", num))
end

-- function: wait signal
-- argument: string key
--           number timeout in second
--           number flag to wait
-- return nil if timeout in wait
--
local function wait_signal(key, timeout)
    local timeout = round(timeout, 1) * 10
    for i=0, timeout do
        local val, flag = shmem:get(key)
        if val then
            if flag == SUCCEEDED then
                return true
            elseif flag == FAILED then
                return nil
            else
                -- do nothing
            end
            sleep(0.1)
        else
            return nil
        end
    end
    return nil
end

-- function: serialize_msg
-- argument: table msg
--     hash table {key1=val1, key2=val2,....}
-- return: string
--     should be 'key1=val1\nkey2=val2\n....\n'
--
local function serialize_msg (msg)
    local str = ''
    for k,v in pairs(msg) do
        str = str .. k .. '=' .. tostring(v) .. '\n'
    end
    return str
end

-- function: deserialize_msg
-- arguments: string str: recieved message from tirex
--     should be 'key1=val1\nkey2=val2\n....\n'
-- return: table
--     hash table {key1=val1, key2=val2,....}
local function deserialize_msg (str)
    local msg = {}
    for line in gmatch(str, "[^\n]+") do
        local m,_,k,v = find(line,"([^=]+)=(.+)")
        if  k ~= '' then
            msg[k]=v
        end
    end
    return msg
end

local function get_key(map, mx, my, mz)
    return format("%s:%d:%d:%d", map, mx, my, mz)
end

--
--  if key exist, it returns false
--  else it returns true
--
local function get_handle(key, val, timeout, flag)
    local success,err,forcible = shmem:add(key, val, timeout, flag)
    if success == false then
	if err == 'exists' then
            local prev_val, prev_flag = shmem:get(key)
            local prev_flag = tonumber(prev_flag) or 0
            if prev_flag < SUCCEEDED then
                local prev_msg = deserialize_msg(prev_val)
                local msg = deserialize_msg(val)
                if prev_msg and prev_msg["prio"] > msg["prio"] then
                    shmem:replace(key, val, timeout, flag)
                    return true
		end
	    else
	        return nil
	    end
	else
	    return nil
        end
    else
        return true
    end
    return nil
end

-- function: remove_handle
-- argument: string key
-- return: nil if failed
local function remove_handle(key)
    return shmem:delete(key)
end

-- ========================================================
--  It does not share context and global vals/funcs
--
local tirex_bk_handler
tirex_bk_handler = function (premature)
    local tirexsock = 'unix:/var/run/tirex/master.sock'
    local tirex_cmd_max_size = 512
    local shmem = ngx.shared.osm_tirex
    local REQUEST   = 100
    local SEND      = 200
    local SUCCEEDED = 300
    local FAILED    = 400

    -- here we cannot refer func so define again
    local deserialize_msg = function (str)
        local msg = {}
        for line in gmatch(str, "[^\n]+") do
            local m,_,k,v = find(line,"([^=]+)=(.+)")
            if  k ~= '' then
                msg[k]=v
            end
        end
        return msg
    end

    if premature then
        -- clean up
        shmem:delete('_tirex_handler')
        return
    end

    local udpsock = ngx.socket.udp()
    udpsock:setpeername(tirexsock)
    udpsock:settimeout(0)

    while true do
        -- ngx.select(shmem, udpsock)
        -- send requests first...
        local indexes = shmem:get_keys()
        for key,index in pairs(indexes) do
            local req, flag = shmem:get(index)
            if flag == REQUEST then
                local ok,err=udpsock:send(req)
                if ok then
                    shmem:replace(index, req, 300, SEND)
                end
            end
        end

        sleep(0.1)

        -- then receive response
        udpsock:settimeout(0)
        local data, err = udpsock:receive(tirex_cmd_max_size)
        if data then
            local msg = deserialize_msg(data)
            local index = get_key(msg["map"], msg["x"], msg["y"], msg["z"])
            local res = msg["result"]
            --send_signal to client context
            local ok
            if res == "ok" then
                shmem:set(index, res, 300, SUCCEEDED)
            else
                shmem:set(index, res, 300, FAILED)
            end
        else
            -- err can be 'timeout', 'partial write', 'closed', 
            -- 'buffer too small' or 'out of memory'
            -- do nothing at this time
        end
    end
    udpsock:close()
end

local function background_enqueue_request(map, x, y, z, priority)
    local mx = x - x % 8
    local my = y - y % 8
    local mz = z
    local id = time()
    local priority = tonumber(priority)
    local index = get_key(map, mx, my, mz)
    local req = serialize_msg({
        ["id"]   = tostring(id);
        ["type"] = 'metatile_enqueue_request';
        ["prio"] = priority;
        ["map"]  = map;
        ["x"]    = mx;
        ["y"]    = my;
        ["z"]    = mz})
    local ok = get_handle(index, req, 300, REQUEST)
    if not ok then
        return nil
    end
    local handle = get_handle('_tirex_handler', 0, 0, SPECIAL)
    if handle then
        -- only single light thread can handle Tirex
        timerat(0, tirex_bk_handler)
    end

    return true
end


-- function: send_tirex_request
-- return: resulted msg{}
local function send_tirex_request(req)
    local udpsock = udp()
    udpsock:setpeername(tirexsock)
    local ok,err=udpsock:send(req)
    if not ok then
        udpsock:close()
        return nil
    end
    local data, err = udpsock:receive(tirex_cmd_max_size)
    udpsock:close()
    if not data then
        return nil
    end
    local msg = deserialize_msg(data)
    return msg
end

-- funtion: send_request
-- argument: map, x, y, z
-- return:   true or nil
--
function send_request (map, x, y, z)
    return enqueue_request(map, x, y, z, 1)
end

--[[
Buckets definition in default
  Name                 Priority
  ------------------------------
  live                   1-   9
  important             10-  19
  background            20-
  ------------------------------
--]]
-- funtion: enqueue_request
-- argument: map, x, y, zoom, priority
--     priority = 1-10 for live requests
-- return:   true or nil
--
function enqueue_request (map, x, y, z, priority)
    local mx = x - x % 8
    local my = y - y % 8
    local mz = z
    local id = time()
    local priority = tonumber(priority)
    local index = get_key(map, mx, my, mz)
    local req = serialize_msg({
        ["id"]   = tostring(id);
        ["type"] = 'metatile_enqueue_request';
        ["prio"] = priority;
        ["map"]  = map;
        ["x"]    = mx;
        ["y"]    = my;
        ["z"]    = mz})
    local ok = get_handle(index, req, 300, GOTHANDLE)
    if not ok then
        return wait_signal(index, 30)
    end
    local msg = send_tirex_request(req)
    if not msg then
        return send_signal(index, 300, FAILED)
    end
    local index = get_key(msg["map"], msg["x"], msg["y"], msg["z"])
    local res = msg["result"]
    if res == "ok" then
        return send_signal(index, 300, SUCCEEDED)
    else
        return send_signal(index, 300, FAILED)
    end
end

-- funtion: dequeue_request
-- argument: map, x, y, z, priority
-- return:   true or nil
--
function dequeue_request (map, x, y, z, priority)
    local mx = x - x % 8
    local my = y - y % 8
    local mz = z
    local id = time()
    local priority = tonumber(priority)
    local index = get_key(map, mx, my, mz)
    local req = serialize_msg({
        ["id"]   = tostring(id);
        ["type"] = 'metatile_remove_request';
        ["prio"] = priority;
        ["map"]  = map;
        ["x"]    = mx;
        ["y"]    = my;
        ["z"]    = mz})
    local ok = get_handle(index, req, 300, GOTHANDLE)
    if not ok then
        return wait_signal(index, 30)
    end
    local msg = send_tirex_request(req)
    if msg then
        local res = msg["result"]
        if res == "ok" then
            return send_signal(index, 300, SUCCEEDED)
        else
            return send_signal(index, 300, FAILED)
        end
    end
end

-- function: ping()
-- return: true or nil
function ping()
    -- Create request command
    local req = serialize_msg({["type"] = 'ping'})
    local msg = send_tirex_request(req)
    if not msg then
        return nil
    end
    if msg["result"] ~= 'ok' then
        return nil
    end
    return true
end

-- funtion: enqueue_request_with_larger_zoom
-- argument: map, x, y, zoom, maxzoom, priority
-- return:   true or nil
--
function request (map, x, y, z1, z2, priority)
    local z2 = tonumber(z2)
    local z1 = tonumber(z1)
    if z1 > z2 then
        return nil
    end
    local priority = tonumber(priority)
    local np = priority + 10
    -- assume that live priority is processed on 'live' and is in 1-9 range.
    -- and larger zoom rendering is on 'important' in 10-19 range.
    local res = enqueue_request(map, x, y, z1, priority)
    if not res then
        return nil
    end
    if z1 == z2 then
        return true
    end
    for i = 1, z2 - z1 do
        local nx, ny = osm_tile.zoom_num(x, y, z1, z1 + i)
        background_enqueue_request(map, nx, ny, z1 + i, np + i)
    end
    return true
end

function cancel (map, x, y, z1, z2, prirority)
    local z2 = tonumber(z2)
    local z1 = tonumber(z1)
    if z1 > z2 then
        return nil
    end
    local priority = tonumber(priority)
    for i = 0, z2 - z1 do
        local nx, ny = osm_tile.zoom_num(x, y, z1, z1 + i)
        dequeue_request(map, nx, ny, z1 + i, priority)
    end
    return true
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
