name "luasec"
version "0.4"

dependency "openssl"
dependency "luarocks"

build do
  command "#{install_dir}/embedded/luajit/bin/luarocks install #{name} #{version} OPENSSL_DIR=#{install_dir}/embedded"
end
