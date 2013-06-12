local dogs = ngx.shared.dogs
local name = ngx.var.arg_name

if name == nil then ngx.say("need to pass name= in query string") end

local age = dogs:get(name)
if age then
  ngx.say(name .. ":" .. age .. "\n")
else
  ngx.say(name .. " not found")
end

