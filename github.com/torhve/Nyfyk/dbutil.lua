-- Postfix db helper utility
local setmetatable = setmetatable
local ngx = ngx
local cjson = require "cjson"
local select = select
local table = table
local pairs = pairs
local unpack = unpack

module(...)

local mt = { __index = _M }

function trim(s)
  if not s then return '' end
  
  return (s:gsub('^%s*(.-)%s*$', '%1'))
end

function escapePostgresParam(...)
  local url      = '/postgresescape?param='
  local requests = {}
  
  for i = 1, select('#', ...) do
    local input = select(i, ...)
    local param
    if not input or input == ngx.null then
        param = ''
    else
        param = ngx.escape_uri(input)
    end
    
    table.insert(requests, {url .. param})
  end
  
  local results = {ngx.location.capture_multi(requests)}
  for k, v in pairs(results) do
    results[k] = trim(v.body)
  end
  
  return unpack(results)
end

function quote(...)
    return escapePostgresParam(...)
end

-- The function sending subreq to nginx postgresql location with rds_json on
-- returns json body to the caller
function dbreq(sql, donotdecode, log)
    if log then 
        ngx.log(ngx.ERR, '-*- SQL -*-: ' .. sql)
    end

    local params = {
        method = ngx.HTTP_POST,
        body   = sql
    }
    local result = ngx.location.capture("/pg", params)
    if result.status ~= ngx.HTTP_OK or not result.body then
        return nil
    end
    local body = result.body
    if donotdecode then
        return body
    end
    return (cjson.decode(body) or {})
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        ngx.log(ngx.ERR, 'attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
