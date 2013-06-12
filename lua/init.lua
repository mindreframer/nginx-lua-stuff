--[[ 在共享字典模块中初始化配置参数，便于程序块之间共享配置参数，读取配置参数 ]]
--file: init.lua
--@author: xiangchao<cloudaice@gmail.com>

package.path = package.path..';lua/?.lua'

local config_dict = ngx.shared.configs
local configs = require 'config'


table.tostring = function(t)
    local mark = {}
    local assign = {}
    local function ser_table(tb1, parent)
        mark[tb1] = parent
        local tmp = {}
        for k, v in pairs(tb1) do
            local key = type(k) == "number" and "["..k.."]" or "["..string.format("%q", k).."]"
            if type(v) == 'table' then
                local dotkey = parent..key
                if mark[v] then
                    table.insert(assign, dotkey.."="..mark[v].."\"")
                else
                    table.insert(tmp, key.."="..ser_table(v, dotkey))
                end
            elseif type(v) == "string" then
                table.insert(tmp, key.."="..string.format("%q", v))
            elseif type(v) == "number" or type(v) == "boolean" then
                table.insert(tmp, key.."="..tostring(v))
            end
        end
        return "{"..table.concat(tmp, ',').."}"
    end
    return "do local ret="..ser_table(t, 'ret')..table.concat(assign, " ").."return ret end"
end

table.loadstring = function(strData)
    local f = loadstring(strData)
    if f then
        return f()
    end
end


-- 初始化commands配置
local commands = table.tostring(configs.commands)
local succ, err, forcible = config_dict:set('commands', commands)
if not succ then
    ngx.log(ngx.INFO, 'set commands err: '..err)
    ngx.exit(500)
end

-- test commands 
local commands = config_dict:get('commands')
commands = table.loadstring(commands)
for a, b in pairs(commands) do
    ngx.log(ngx.INFO, a)
end


-- 初始化apps配置
local apps = table.tostring(configs.apps)
succ, err, forcible = config_dict:set('apps', apps)
if not succ then
    ngx.log(ngx.INFO, 'set apps err: '..err)
    ngx.exit(500)
end

-- 初始化patterns配置
local patterns = table.tostring(configs.patterns)
succ, err, forcible = config_dict:set('patterns', patterns)
if not succ then
    ngx.log(ngx.INFO, 'set patterns err: '..err)
    ngx.exit(500)
end

-- 初始化types参数
local types = table.tostring(configs.types)
succ, err, forcible = config_dict:set('types', types)
if not succ then
    ngx.log(ngx.INDO, 'set types err: '..err)
    ngx.exit(500)
end
