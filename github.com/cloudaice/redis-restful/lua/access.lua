--file access.lua
--@author: xiangchao<cloudaice@gmail.com>

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

-- 无法使用":"为table添加方法, 这里使用"."为table添加方法
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

table.loadstring = function(strData)
    local f = loadstring(strData)
    if f then
        return f()
    end
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

local commands = configs:get('commands')
if not commands then
    ngx.log(ngx.INFO, 'err when get commands')
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
local uri_splits = uri:split('/')

-- 检查该app是否已经注册
if not table.has_value(apps, uri_splits[1]) then
    ngx.log(ngx.INFO, 'err '..uri_splits[1]..' in uri')
    ngx.exit(400)
end

-- 检查在url中的该类型是否符合要求
if not table.has_value(types, uri_splits[2]) then
    ngx.log(ngx.INFO, 'err '..uri_splits[2]..' in uri')
    ngx.exit(400)
end

-- 检查该redis命令是否合法
if not table.has_key(commands, uri_splits[#uri_splits]) then
    ngx.log(ngx.INFO, 'err '..uri_splits[#uri_splits]..' in uri')
    ngx.exit(400)
end


-- 检查该url匹配到配置文件中的哪个表达式
for i = 1, #patterns do
    local pattern = string.match(uri, patterns[i]) 
    ngx.log(ngx.INFO, 'matching '..patterns[i])
    if pattern then
        ngx.log(ngx.INFO, 'uri is matched whith '..patterns[i])
        local succ, err, forcble = configs:set('pattern', i)     --记录匹配到的uri，用于content中读取
        if not succ then
            ngx.log(ngx.INFO, 'set pattern err '..err)
            ngx.exit(500)
        end
        break
    end
end

-- pattern: 匹配到的url模式
local pattern, flag = configs:get('pattern')
if not flag == 0 then
    ngx.log(ngx.INFO, 'no pattern match this uri')
    ngx.exit(400)
end

local request_args = nil
local method = ngx.req.get_method()
if method == 'POST' then
    ngx.req.read_body()
    request_args = ngx.req.get_post_args()
else
    request_args = ngx.req.get_uri_args()
end


-- 检查该请求是否匹配到配置文件中的一个方法
local arg_index = nil
local cmd = uri_splits[#uri_splits]
for i = 1, #commands[cmd] do
    local arg = commands[cmd][i]
    if method == arg['method'] then
       if check_args(request_args, arg) then
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
else
    local succ, err, forcble = configs:set('arg_index', arg_index)
    if not succ then
        ngx.log(ngx.INFO, 'set arg_index error')
        ngx.exit(404)
    end
end
