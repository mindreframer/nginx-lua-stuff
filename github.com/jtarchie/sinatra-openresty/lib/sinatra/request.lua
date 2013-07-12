local Request = {}
Request.__index = Request

function Request:new()
  return setmetatable({
    request_method=ngx.req.get_method(),
    current_path=ngx.var.uri
  }, self)
end

function Request:params()
  self.params_values = self.params_values or ngx.req.get_uri_args()
  return self.params_values
end

return Request
