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
  "underscore"
}
build = {
  type = "builtin",
  modules = {
    ["sinatra"] = "lib/sinatra.lua",
    ["sinatra.app"] = "lib/sinatra/app.lua",
    ["sinatra.request"] = "lib/sinatra/request.lua",
    ["sinatra.response"] = "lib/sinatra/response.lua"
  }
}
