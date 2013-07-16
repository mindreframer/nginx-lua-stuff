name "geoip"
version "1.5.0"

source :url => "http://www.maxmind.com/download/geoip/api/c/GeoIP-#{version}.tar.gz",
       :md5 => "57bc400b5c11057a4cab00e1c5cf3f00"

relative_path "GeoIP-#{version}"

env = {
  "LDFLAGS" => " -pie -L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "CFLAGS" => " -fPIC -L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
}

build do
  command ["./configure",
           "--prefix=#{install_dir}/embedded"].join(" "), :env => env
  
  command "make -j #{max_build_jobs}", :env => env
  command "make install"
end
