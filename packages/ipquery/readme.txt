wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar zxvf libiconv-1.14.tar.gz
./configure 
make 
make install



gcc -Wall -O2 -shared -fPIC -I/usr/local/luajit/include/luajit-2.0 -liconv ip.c ip_lua_bingding.c -o ipquery.so


run: 
vi /etc/ld.so.conf
add /usr/local/lib

/sbin/ldconfig


