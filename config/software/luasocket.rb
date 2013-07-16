name "luasocket"
version "2.0.2"

dependency "luarocks"

build do
  command "#{install_dir}/embedded/luajit/bin/luarocks install #{name} #{version}"
end
