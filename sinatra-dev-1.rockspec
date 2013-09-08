package = "sinatra"
version = "dev-1"
source = {
  url = "git://github.com/jtarchie/sinatra-openresty.git"
}
description = {
  summary = "Sinatra port for OpenResty",
  detailed = [[Sinatra port for OpenResty in Lua.]],
  homepage = "http://jtarchie.github.com/sinatra-openresty/",
  maintainer = "JT Archie <jtarchie@gmail.com>",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
  "underscore",
  "lua-cjson",
  "busted",
  "luasocket"
}
build = {
  type = "builtin",
  modules = {
    ["sinatra"] = "lib/sinatra.lua",
    ["sinatra.app"] = "lib/sinatra/app.lua",
    ["sinatra.app.helper"] = "lib/sinatra/app/helper.lua",
    ["sinatra.pattern"] = "lib/sinatra/pattern.lua",
    ["sinatra.request"] = "lib/sinatra/request.lua",
    ["sinatra.response"] = "lib/sinatra/response.lua",
    ["sinatra.utils"] = "lib/sinatra/utils.lua"
  }
}
