local table, _ = table, require("underscore")
local App, Request, Response, Pattern, Utils =
  {}, require("sinatra/request"), require("sinatra/response"), require("sinatra/pattern"), require("sinatra/utils")

App.__index = App

function log(...)
  ngx.log(ngx.ERR, "SINATRA: ", ...)
end

function halt(...)
  error(Response:new(...))
end

function App:new()
  local self = setmetatable({
    routes={}
  }, self)
  return self
end

function App:delete(pattern, callback) self:set_route('DELETE', pattern, callback) end
function App:get(pattern, callback) self:set_route('GET', pattern, callback) end
function App:head(pattern, callback) self:set_route('HEAD', pattern, callback) end
function App:link(pattern, callback) self:set_route('LINK', pattern, callback) end
function App:options(pattern, callback) self:set_route('OPTIONS', pattern, callback) end
function App:patch(pattern, callback) self:set_route('PATCH', pattern, callback) end
function App:post(pattern, callback) self:set_route('POST', pattern, callback) end
function App:put(pattern, callback) self:set_route('PUT', pattern, callback) end
function App:unlink(pattern, callback) self:set_route('UNLINK', pattern, callback) end

function App:set_route(method, pattern, callback)
  self.routes[method] = self.routes[method] or {}
  table.insert(self.routes[method], {
    method=method,
    pattern=Pattern:new(pattern),
    callback=callback
  })
end

function process_route(request, route)
  local matches = { route.pattern:match(request.current_path) }
  if #matches > 0 then
    matches = _.map(matches, Utils.unescape)
    local params = _.extend(request:params(), {splat={},captues=matches})
    _.each(_.zip(route.pattern.keys, matches), function(matched)
      local key, value = matched[1], matched[2]
      if _.isArray(params[key]) then
        table.insert(params[key], value)
      else
        params[key] = value
      end
    end)
    local route_env = setmetatable({
      request=request,
      params=params
    }, { __index = _G})
    local callback = setfenv(route.callback, route_env)
    halt(callback(unpack(matches)))
  end
end

function App:apply_routes(request)
  local routes = self.routes[request.request_method]
  for index, route in ipairs(routes) do
    process_route(request, route)
  end

  halt(404)
end

function process_request(app)
  local request = Request:new()
  app:apply_routes(request)
end

function App:run()
  local ok, response = pcall(process_request, self)
  if getmetatable(response) == Response then
    response:send()
    return response
  else
    log(tostring(response))
    return response
  end
end

return App
