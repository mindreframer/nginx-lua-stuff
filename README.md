yagamiko
========

yagamiko is a api server project implementation by lua &amp;&amp; nginx ( openresty) .

Project Struct
========
luajitlib -> /usr/local/luajit/lib     luajit library
lualib -> /usr/local/lualib/           lualib library  
yagami                                 yagami framework
yagamiko                               yagamiko backend http api server


How to use
========
chmod -R 777 /path/yagamiko/nginx_runtime
cd /path/yagamiko && ./bin/start.sh    start service
cd /path/yagamiko && ./bin/reload.sh   reload service
cd /path/yagamiko && ./bin/stop.sh     stop service

  




