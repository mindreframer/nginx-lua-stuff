local sinatra = require('sinatra');
local json = require("cjson")

local app = sinatra.app:new()

app:get("/", function()
  return "Hello, World"
end)

app:get("/:name", function(name)
  if (request.headers['Accept'] == 'application/json') then
    self:status(201)
    self:content_type("application/json")
    self:body(json.encode({name=name}))
  else
    return "Hello, " .. params.name;
  end
end)

app:get("/age/:age", function(age)
  if (params.name) then
    return params.name .. " are " .. tostring(age) .. " years old."
  else
    return "You are " .. tostring(age) .. " years old."
  end
end)

app:run()

