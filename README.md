# lua-resty-riak #

lua-resty-riak - Lua riak protocol buffer client driver for the ngx_lua
based on the cosocket API.

Originally based on the
[lua-resty-memcached](https://github.com/agentzh/lua-resty-memcached)
library.

Influence by [riak-client-ruby](https://github.com/basho/riak-ruby-client/)

## Status ##

This library is currently _alpha_ quality. It passes all its unit
tests. A few billion requests per day are handled by it however.

## Description ##

This Lua library is a riak protocol buffer client driver for the [ngx_lua nginx module](http://wiki.nginx.org/HttpLuaModule)

This Lua library takes advantage of ngx_lua's cosocket API, which ensures
100% nonblocking behavior.

Note that at least [ngx\_lua 0.5.0rc29](https://github.com/chaoslawful/lua-nginx-module/tags) or [ngx\_openresty 1.0.15.7](http://openresty.org/#Download) is required.

Depends on the following Lua modules:

* lua-pb - https://github.com/Neopallium/lua-pb
* struct - http://www.inf.puc-rio.br/~roberto/struct/
* lpack - http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/#lpack 

## Synopsis ##

    lua_package_path "/path/to/lua-resty-riak/lib/?.lua;;";
    location /t {
        content_by_lua '
            require "luarocks.loader"
            local riak = require "resty.riak"
            local client = riak.new()
            local ok, err = client:connect("127.0.0.1", 8087)
            if not ok then
                ngx.log(ngx.ERR, "connect failed: " .. err)
            end
            local bucket = client:bucket("test")
            local object = bucket:new("1")
            object.value = "test"
            object.content_type = "text/plain"
            local rc, err = object:store()
            ngx.say(rc)
            local object, err = bucket:get("1")
            if not object then
                ngx.say(err)
            else
                ngx.say(object.value)
            end
            client:close()
        ';
    }

## Usage ##

See the [generated docs](http://bakins.github.io/lua-resty-riak/)  for
usage and examples.

**Note** The high level API should be considered _stable_ - ie will
  not break between minor versions. The _low-level_ or _raw_ API
  should not be considered stable. 

## Limitations ##

* This library cannot be used in code contexts like *set_by_lua*, *log_by_lua*, and
*header_filter_by_lua* where the ngx\_lua cosocket API is not available.
* The `resty.riak` object instances  cannot be stored in a Lua variable at the Lua module level,
because it will then be shared by all the concurrent requests handled by the same nginx
 worker process (see [Data Sharing within an Nginx Worker](http://wiki.nginx.org/HttpLuaModule#Data\_Sharing\_within\_an\_Nginx_Worker) ) and
result in bad race conditions when concurrent requests are trying to use the same instances.
You should always initiate these objects in function local
variables or in the `ngx.ctx` table. These places all have their own data copies for
each request.


## TODO ##

## Author ##
Brian Akins <brian@akins.org>

Heavily influenced by  Zhang "agentzh" Yichun (章亦春) <agentzh@gmail.com>.

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2012, by Brian Akins <brian@akins.org>.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## See Also ##
* [ngx_lua module](http://wiki.nginx.org/HttpLuaModule)
* [riak-client-ruby](https://github.com/basho/riak-ruby-client/)
* [Riak Protocol Buffer API](https://wiki.basho.com/PBC-API.html)
