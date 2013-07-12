#!/usr/bin/env lua

module('yagami.debug',package.seeall)

local front      = require('yagami.front')
local functional = require('yagami.functional')

local debug_getinfo = debug.getinfo
local string_format = string.format

function traceback ()
    for level = 1, math.huge do
        local info = debug_getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then   -- is a C function?
            print(level, "C function")
        else   -- a Lua function
            print(string_format("[%s]:%d", info.short_src,
                                info.currentline))
        end
    end
end

function debug_utils()
    local debug_info={info={}}
    
    function _debug_hook(event, extra)
        local info = debug_getinfo(2)
        if info.currentline<=0 then return end
        --if (string.find(info.short_src,"yagami/luasrc") or 
        --string.find(info.short_src,"yagami/lualib")) then
        --return
        --end
        info.event=event
        table.insert(debug_info.info,info)
    end

    function _debug_clear()
        debug_info.info={} 
    end

    function _debug_info()
        return debug_info
    end
    
    return _debug_hook, _debug_clear, _debug_info
end


debug_hook, debug_clear, debug_info = debug_utils()


function debug_info2html()
    
    local ret = front.DEBUG_INFO_CSS .. [==[
                <div id="yagami-table-of-contents">
                <h2>DEBUG INFO </h2>
                <div id="yagami-text-table-of-contents"><ul>
        ]==]
    for _, info in ipairs(debug_info().info) do
        local estr= "unkown event"
        if info.event=="call" then
            estr = " -> "
        elseif info.event=="return" then
            estr = " <- "
        end
        local sinfo=(string_format("<li>%s [function %s] in file [%s]:%d,</li>\r\n",
                                   estr,
                                   tostring(info.name),
                                   info.short_src,
                                   info.currentline))
        ret = ret .. sinfo
    end
    return ret .. "</ul></div></div>"
end


function debug_info2text()
    local ret = "DEBUG INFO:\n"
    for _, info in ipairs(debug_info().info) do
        local estr = "unkown event"
        if info.event=="call" then
            estr = " -> "
        elseif info.event=="return" then
            estr = " <- "
        end
        local sinfo=(string_format("%s [function %s] in file [%s]:%d,\n",
                                   estr,
                                   tostring(info.name),
                                   info.short_src,
                                   info.currentline))
        ret = ret .. sinfo
    end
    return ret
end

