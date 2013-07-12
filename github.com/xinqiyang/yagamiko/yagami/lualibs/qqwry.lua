--[[
qqwry.lua
IP => Location query with qqwry.dat
qqwry.dat format refer to http://lumaqq.linuxsir.org/article/qqwry_format_detail.html

NOTE: ipdat_path should be point to the directory qqwry.dat at 

author: Lance Li <lancelijade@gmail.com>
version: 0.93.1
last modified: 2011-08-30 16:46 
]]--

local math = require("math")
local io = require("io")
local math = require("math")
local table = require("table")
local string = require("string")

module("qqwry")
--set ip file path  use the gloable path
local ipdat_path = "/source/freeflare/server/yagamiko/conf/ip/"
local qqwry = nil

-- binary string to number big-endian
function s2nBE(s)
    if s == nil then return nil end
    local r = 0
    for j = s:len(), 1, -1 do
        r = r + s:sub(j, j):byte() * 256 ^ (j - 1)
    end
    return r
end

function ip2long(s)
    if s == nil then return nil end
    local r = 0
    local i = 3
    for d in s:gmatch("%d+") do
        r = r + d * 256 ^ i
        i = i - 1
        if i < 0 then break end
    end
    return r
end

function long2ip(i)
    if i == nil then return nil end
    local r = ""
    for j = 0, 3, 1 do
        r = i % 256 .. "." .. r
        i = math.floor(i / 256)
    end
    return r:sub(1, -2)
end

-- locate absolute ip info offset from index area
local function locateIpIndex(ip, offset1, offset2)
    local curIp, offset, nextIp
    local m = math.floor((offset2 - offset1) / 7 / 2) * 7 + offset1
    qqwry:seek("set", m)
    local count = 0
    while offset == nil do
        curIp = s2nBE(qqwry:read(4))
        offset = s2nBE(qqwry:read(3))
        nextIp = s2nBE(qqwry:read(4))
        if nextIp == nil then nextIp = 2 ^ 32 end
        if curIp <= ip and ip < nextIp then
            break
        elseif ip < curIp then
            offset2 = m
        else
            offset1 = m + 7
        end
        m = math.floor((offset2 - offset1) / 7 / 2) * 7 + offset1
        qqwry:seek("set", m)
        offset = nil
        count = count + 1
        if count > 200 then break end
    end
    if count > 200 then return nil end
    return offset
end

-- get location info from given offset
-- param  offset, offset for return (if not set offsetR, the function will return current pos)
-- return location offset, next location info offset
local function getOffsetLoc(offset, offsetR)
    local loc = ""
    qqwry:seek("set", offset)
    local form = qqwry:read(1)

    if form ~= "\1" and form ~= "\2" then
        qqwry:seek("set", offset)
        local b = qqwry:read(1)
        while b ~= nil and b ~= "\0" do
            loc = loc .. b
            b = qqwry:read(1)
        end
        if offsetR ~= nil then
            return loc, offsetR
        else
            return loc, qqwry:seek()
        end

    else
        local offsetNew = s2nBE(qqwry:read(3))
        if form == "\2" then
            return getOffsetLoc(offsetNew, offset + 4)
        else
            return getOffsetLoc(offsetNew)
        end
    end
end


-- change to memory
function query(ip)
    qqwry = io.open(ipdat_path .. "qqwry.dat", "r")
    if qqwry == nil then return nil, "qqwry.dat not found" end

    local offset = locateIpIndex(ip2long(ip), s2nBE(qqwry:read(4)), s2nBE(qqwry:read(4)))
    local loc1, loc2
    loc1,offset = getOffsetLoc(offset + 4)
    loc2 = getOffsetLoc(offset)
    qqwry:close()
    return {loc1, loc2}
end

-- query
function version()
    return query("255.255.255.0")
end

