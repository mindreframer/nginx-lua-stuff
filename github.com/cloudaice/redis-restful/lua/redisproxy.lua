--file redisproxy.lua
--@author: xiangchao<cloudaice@gmail.com>

local redis = require "resty.redis"
local cjson = require "cjson"
local red = redis:new()
red:set_timeout(1000)       -- 1 sec
local ok, err = red:connect('127.0.0.1', 6379);
if not ok then
    ngx.say('failed to connect', err)
    return
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end


function struct_args(args)                --包装命令和参数
    local str_args = {}
    for i = 1, #args do
        str_args[#str_args + 1] = '\''..args[i]..'\''
    end
    local args_string = "return "..table.concat(str_args,',')
    return args_string
end
    

-- 无法使用":"为table添加方法, 这里使用"."为table添加方法
table.loadstring = function(strData)
    local f = loadstring(strData)
    if f then
        return f()
    end
end


table.has_key = function (self, key)
    if self[key] then
        return true
    else 
        return false
    end
end


table.has_value = function(self, value) 
    for i = 1, #self do
        if self[i] == value then
            return true
        end
    end
    return false
end


-- req_args为空时,req_args = {}
function check_args(req_args, conf_args)        
    local req_args_length = 0
    for k, v in pairs(req_args) do
        req_args_length = req_args_length + 1
    end

    if req_args_length ~= conf_args['args_len'] then
        ngx.log(ngx.INFO, 'error args_len '..#req_args..' '..conf_args['args_len'])
        return false
    end
    
    for i = 1, #conf_args['args'] do
        local arg = conf_args['args'][i]
        if not req_args[arg.name] then 
            return false
        end
    end
    return true
end


local configs = ngx.shared.configs

local commands  = configs:get('commands')
if not commands then
    ngx.log(ngx.INFO, 'err in get commands')
    ngx.exit(500)
end
commands = table.loadstring(commands)

local patterns = configs:get('patterns')
if not patterns then
    ngx.log(ngx.INFO, 'err when get patterns')
    ngx.exit(500)
end
patterns = table.loadstring(patterns)

local types = configs:get('types')
if not types then
    ngx.log(ngx.INFO, 'err when get types')
    ngx.exit(500)
end
types = table.loadstring(types)

local apps = configs:get('apps')
if not apps then
    ngx.log(ngx.INFO, 'err when get apps')
    ngx.exit(500)
end
apps = table.loadstring(apps)


local uri = ngx.var.uri
local uri_args = uri:split('/')

-- 检查该app是否已经注册
if not table.has_value(apps, uri_args[1]) then
    ngx.log(ngx.INFO, 'err '..uri_args[1]..' in uri')
    ngx.exit(400)
end

-- 检查在url中的该类型是否符合要求
if not table.has_value(types, uri_args[2]) then
    ngx.log(ngx.INFO, 'err '..uri_args[2]..' in uri')
    ngx.exit(400)
end

-- 检查该redis命令是否合法
if not table.has_key(commands, uri_args[#uri_args]) then
    ngx.log(ngx.INFO, 'err '..uri_args[#args]..' in uri')
    ngx.exit(400)
end


local cmd = uri_args[#uri_args]
local method = ngx.req.get_method()
local req_args = nil
if method == 'POST' then
    ngx.req.read_body()
    req_args = ngx.req.get_post_args()
elseif method == 'GET' then
    req_args = ngx.req.get_uri_args()
end

local confdocs = commands[cmd]
if not confdocs then
    ngx.log(ngx.INFO, 'err to get cmd config')
    ngx.exit(500)
end

-- 获取请求的参数
local redis_args = {}
local arg_index = nil
for i = 1, #commands[cmd] do
    local arg = commands[cmd][i]
    if method == arg['method'] then
       if check_args(req_args, arg) then
           arg_index = i
           break
       end
    else
        ngx.log(ngx.INFO, 'method error '..method..' '..arg['method'])
    end
end
if not arg_index then
    ngx.log(ngx.INFO, 'error in request args')
    ngx.exit(404)
end

for i = 1, #confdocs[arg_index]['args'] do
    local arg = confdocs[arg_index]['args'][i]
    if arg.separate then
        sep_args = req_args[arg.name]:split(',')
        for j = 1, #sep_args do
            table.insert(redis_args, sep_args[j])
        end
    else
        table.insert(redis_args, req_args[arg.name])
    end
end

-- 获取匹配模式
local pattern = nil
for i = 1, #patterns do
    local pat = string.match(uri, patterns[i]) 
    ngx.log(ngx.INFO, 'matching '..patterns[i])
    if pat then
        ngx.log(ngx.INFO, 'uri is matched whith '..patterns[i])
        pattern = i
        break
    end
end
if not pattern then
    ngx.log(ngx.INFO, 'err get pattern')
    ngx.exit(404)
end


local cmd_ok, cmd_err
if pattern == 1 then
    local key = uri_args[3]
    local cmd = uri_args[#uri_args]
    local args_string = struct_args(redis_args)
    cmd_ok, cmd_err = red[cmd](red, key, loadstring(args_string)())
elseif pattern == 2 then
    local cmd = uri_args[#uri_args]
    local args_string = struct_args(redis_args)
    cmd_ok, cmd_err = red[cmd](red, loadstring(args_string)())
elseif pattern == 3 then
    local key = uri_args[3] 
    local field = uri_args[5]
    local cmd = uri_args[#uri_args]
    local args_string = struct_args(redis_args)
    cmd_ok, cmd_err = red[cmd](red, key, field, loadstring(args_string)())
elseif pattern == 4 then
    local key = uri_args[3]
    local member = uri_args[5]
    local cmd = uri_args[#uri_args]
    local args_string = struct_args(redis_args)
    cmd_ok, cmd_err = red[cmd](red, key, member, loadstring(args_string)())
else
    ngx.log(ngx.INFO, 'error pattern')
    ngx.exit(500)
end

if not cmd_ok then
    ngx.say("failed to process"..cmd, err)
    return
end

local ok, err = red:set_keepalive(10000,100)
if not ok then
    ngx.say('failed to set keepalive: ', err)
    return
end
