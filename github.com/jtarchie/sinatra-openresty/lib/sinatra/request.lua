local class = require '30log'
local Request = class {}
Request.__name = "Request"

function Request:__init()
  self.request_method = ngx.var.request_method
  self.current_path = ngx.var.uri
  self.params = ngx.req.get_uri_args()
  self.headers = ngx.req.get_headers()
end

return Request
