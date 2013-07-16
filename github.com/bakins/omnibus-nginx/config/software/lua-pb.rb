name "lua-pb"
version "master"

dependency "luarocks"

source git: "https://github.com/Neopallium/lua-pb.git"

build do
  command "#{install_dir}/embedded/luajit/bin/luarocks make"
end
