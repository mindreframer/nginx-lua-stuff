About dt 
========

 dt (pronounced "Dit") is an URL Shortening utility built upon the high performance [nginx] HTTP server, using the [embedded Lua interpreter](http://wiki.nginx.org/HttpLuaModule). The nginx Lua module, ngx lua, embeds Lua, via the standard Lua interpreter or LuaJIT 2.0, into Nginx and by leveraging Nginx's subrequests, allows the integration of the powerful Lua threads (Lua coroutines) into the Nginx event model.

 dt is a [PoC](https://en.wikipedia.org/wiki/Proof_of_concept) of how the ngx lua stack can be used to build relatively small yet extremely high performance applications over the very HTTP server stack.


Status
======

 As a PoC application, dt is a work in progress. Basic functionality is provided, although it should be carefully used.
 
 

Architecture
============
 
 dt uses [Redis](http://redis.io/) for persisting information, which includes anything from redirections, private original URL edition and statistics.
 Built using the [lua-resty-redis](https://github.com/agentzh/lua-resty-redis) Redis "connector" by the genius Yichun "agentzh" Zhang, internally relying on the ngx lua Cosocket API, granting a 100% non-blocking behaviour. 
 


 See Also
========
* the ngx lua module: http://wiki.nginx.org/HttpLuaModule
* the [lua-resty-redis](https://github.com/agentzh/lua-resty-redis) library
* the redis wired protocol specification: http://redis.io/topics/protocol
* the [lua-resty-memcached](https://github.com/agentzh/lua-resty-memcached) library

