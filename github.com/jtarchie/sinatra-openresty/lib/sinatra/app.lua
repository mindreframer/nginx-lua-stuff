local class = require "30log"
local table, _ = table, require("underscore")
local Request = require("sinatra/request")
local Response = require("sinatra/response")
local Pattern = require("sinatra/pattern")
local Utils = require("sinatra/utils")
local Helper = require("sinatra/app/helper")

local App = class {}
local noop = function() end

-- default responses
local NotFound = 404

local function log(...)
  ngx.log(ngx.ERR, "SINATRA: ", ...)
end

local function catch(thrown_value, callback, ...)
  local ok, value = pcall(callback, ...)
  if not ok then
    if getmetatable(value) ~= thrown_value then
      error(value)
    else
      return(value.args)
    end
  end
end

local function throw(thrown_value, ...)
  local instance = thrown_value:new()
  instance.args = ...
  error(instance)
end

local Halt, Pass = class {}, class {}
Halt.__name = "Halt"
Pass.__name = "Pass"
function App:pass(...) throw(Pass, ...) end
function App:halt(...) throw(Halt, ...) end

function App:__init()
  self.routes={}
  self.filters={['before']={},['after']={}}
  self.environment='development'
end

function App:delete(pattern, callback) self:set_route('DELETE', pattern, callback) end
function App:get(pattern, callback)
  self:set_route('GET', pattern, callback)
  self:head(pattern, callback)
end
function App:head(pattern, callback) self:set_route('HEAD', pattern, callback) end
function App:link(pattern, callback) self:set_route('LINK', pattern, callback) end
function App:options(pattern, callback) self:set_route('OPTIONS', pattern, callback) end
function App:patch(pattern, callback) self:set_route('PATCH', pattern, callback) end
function App:post(pattern, callback) self:set_route('POST', pattern, callback) end
function App:put(pattern, callback) self:set_route('PUT', pattern, callback) end
function App:unlink(pattern, callback) self:set_route('UNLINK', pattern, callback) end

local function compile(method, pattern, callback)
  return {
    method=method,
    pattern=Pattern:new(pattern),
    callback=callback
  }
end

function App:set_route(method, pattern, callback)
  self.routes[method] = self.routes[method] or {}
  table.insert(self.routes[method], compile(method, pattern, callback))
end

function App:process_route(route, block)
  local request = self.request
  local matches = { route.pattern:match(request.current_path) }
  if #matches > 0 then
    matches = _.map(matches, Utils.unescape)
    local params = _.extend({},request.params, {splat={},captues=matches})
    _.each(_.zip(route.pattern.keys, matches), function(matched)
      local key, value = matched[1], matched[2]
      if _.isArray(params[key]) then
        table.insert(params[key], value)
      else
        params[key] = value
      end
    end)
    local context = setmetatable({
      self=self,
      request=self.request,
      response=self.response,
      params=params
    }, { __index = _G})
    local callback = setfenv(route.callback, context)
    return catch(Pass, block, self, callback(unpack(matches)))
  end
end

function App:after(...) self:add_filter('after', ...) end
function App:before(...) self:add_filter('before', ...) end

function App:add_filter(filter_type, pattern, callback)
  if(_.isFunction(pattern)) then
    callback, pattern = pattern, '*'
  end

  self.filters[filter_type] = self.filters[filter_type] or {}
  table.insert(self.filters[filter_type], compile(filter_type, pattern, callback))
end

function App:setting(key, value)
  if value ~= nil then
    self[key] = value
  end
  return self[key]
end

function App:enable(key) self:setting(key, true) end
function App:disable(key) self:setting(key, false) end

function App:configure(...)
  local envs, block = _.initial({...}), _.last({...})

  if _.isEmpty(envs) or _.include(envs, self.environment) then
    block()
  end
end

function App:process_filters(filter_type)
  local filters = self.filters[filter_type]
  for index, route in ipairs(filters) do
    self:process_route(route, noop)
  end
end

function App:process_routes()
  local pass_block
  self:process_filters('before')

  local routes = self.routes[self.request.request_method]
  for index, route in ipairs(routes) do
    pass_block = catch(Pass, self.process_route, self, route, self.halt)
  end
  if pass_block then self:halt(pass_block()) end
  self:halt(NotFound)
end

function App:dispatch()
  self:invoke(self.process_routes)
  self:process_filters('after')
end

function App:invoke(callback)
  local response = catch(Halt, callback, self)
  self.response:update(response)
end

function App:run()
  self.request = Request:new()
  self.response = Response:new()

  self:invoke(self.dispatch)
  self.response:finish()
  return self.response
end

App:with(Helper)

return App
