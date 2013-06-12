local dogs = ngx.shared.dogs
local name = ngx.var.arg_name
local age = ngx.var.arg_age
if name and age
then 
   dogs:set(name, age)
   ngx.say("STORED")
else 
   ngx.say("Need name and age")
end
