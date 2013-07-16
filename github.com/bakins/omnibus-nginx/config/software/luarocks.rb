name "luarocks"
version "2.0.12"

dependency "nginx"

source url: "http://luarocks.org/releases/luarocks-#{version}.tar.gz", md5: "a1bc938ddf835550917f0cb6964ea516"

relative_path "luarocks-#{version}"

build do
  command ["./configure",
           "--prefix=#{install_dir}/embedded/luajit",
           "--lua-suffix=jit",
           "--with-lua=#{install_dir}/embedded/luajit",
           "--with-lua-include=#{install_dir}/embedded/luajit/include/luajit-2.0",
           "--with-lua-lib=#{install_dir}/embedded/luajit/lib"
          ].join(" ")

  command "make"
  command "make install"
end
