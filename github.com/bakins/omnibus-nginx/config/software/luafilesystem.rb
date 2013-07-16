name "luafilesystem"
version "1.6.2"

dependency "luarocks"

build do
  command "#{install_dir}/embedded/luajit/bin/luarocks install #{name} #{version}"
end
