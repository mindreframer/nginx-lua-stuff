name "mmap_lowmem"
version "master"

source git: "https://github.com/Neopallium/mmap_lowmem.git"

build do
  command "perl -p -i -e 's/(define\s+ENABLE_VERBOSE)\s+1/$1 0/' mmap_lowmem.c"
  command "make"
  command "make install LIBDIR=#{install_dir}/lib"
end
