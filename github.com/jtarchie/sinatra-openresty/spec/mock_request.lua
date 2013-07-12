local MockRequest = {}
MockRequest.__index = MockRequest

function MockRequest:new(app)
  return setmetatable({
    app=app
  }, MockRequest)
end

function MockRequest:request(verb, request_path, headers)
  ngx={
    log=function(...) print(...) end,
    var={
      uri=request_path
    },
    req={
      get_method=function() return verb end,
      get_uri_args=function() return {} end
    },
    say=function() end
  }
  local response = self.app:run()
  return response
end

return MockRequest
