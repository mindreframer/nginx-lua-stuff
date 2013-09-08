local _ = require("underscore")
local Helper = {}

function Helper:is_not_found()
  return self:status() == 404
end

function Helper:is_informational()
  return 100 <= self:status() and self:status() < 200
end

function Helper:is_success()
  return 200 <= self:status() and self:status() < 300
end

function Helper:is_redirect()
  return 300 <= self:status() and self:status() < 400
end

function Helper:is_client_error()
  return 400 <= self:status() and self:status() < 500
end

function Helper:is_server_error()
  return self:status() >= 500
end

function Helper:status(code)
  if code then
    self.response.status = code
  end
  return self.response.status
end

function Helper:body(value)
  self.response.body = value
  return self.response.body
end

function Helper:headers(hash)
  if(_.isObject(hash)) then
    _.extend(self.response.headers, hash)
  end
  return self.response.headers
end

local with_charset = {"application/javascript", "application/xml", "application/xhtml+xml", "application/json", "^text"}
function Helper:content_type(content_type, params)
  params = params or {}
  if not content_type:match('charset') and _.find(with_charset, function(value) return content_type:match(value) end) then
    params['charset'] = params['charset'] or 'utf-8'
  end

  local mime_type = content_type
  if not _.isEmpty(params) then
    local separator = (mime_type:match(';') and ',') or ';'
    mime_type = mime_type .. separator .. _(params).chain()
    :map(function(value, key)
      if value:match('[";,]') then
        value = string.format("%q", value)
      end
      return _.join({key, value}, "=")
    end)
    :join(",")
    :value()
  end

  self:headers({['Content-Type']=mime_type})
  return mime_type
end

function Helper:helpers(...)
  _.extend(self, ...)
end

return Helper
