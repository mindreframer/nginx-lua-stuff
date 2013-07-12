#!/usr/bin/env lua

module('yagami.functional',package.seeall)

local table_insert = table.insert

--[[
-- common functional tools
--]]


function curry(func, ...)
    if select("#", ...) == 0 then return func end
    local args={...}
    local function inner(...)
        local _args={...}
        local real_args={unpack(args)}
        for _,v in ipairs(_args) do table_insert(real_args,v) end
        return func(unpack(real_args))
    end
    return inner
end

function map(func,tab)
    local retv={}
    for k,v in pairs(tab) do
        local rk,rv=func(k,v)
        if rk then
            retv[rk]=rv
        else
            table_insert(retv,rv)
        end
    end
    return retv
end

function any(func,tab)
    for k,v in pairs(tab) do
        if func(k,v) then return true end
    end
    return false
end
    
function filter(func,tab)
    local retv={}
    for k,v in pairs(tab) do
        if func(k,v) then retv[k]=v end
    end
    return retv
end

function fold(func,acc,tab)
    local ret=acc
    for k,v in pairs(tab) do
        ret=func(ret,k,v)
    end
    return ret
end



--[[
-- common lua functions based on functional tools above
--]]

table_keys=curry(map,function(k,_)return nil,k end)
table_values=curry(map,function(_,v)return nil,v end)
table2array=table_values

