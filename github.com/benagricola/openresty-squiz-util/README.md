# Squiz Utils

A [Lua](http://www.lua.org) module for [OpenResty](http://openresty.org) to provide an error-tolerant set of tools allowing for the succinct implementation of logic directly in the webserver configuration file. 

## An Example
Implement an authentication rewrite to redirect authenticated users on HTTP to HTTPS, and unauthenticated users on HTTPS to HTTP. User details are stored in memcache and the memcache key is stored in a HTTP cookie called `authentication_cookie`. Users are authenticated by matching two strings `string-1-to-find-in-session` and `string-2-to-find-in-session` in the session data retrieved from memcache, and a redirection is triggered to the new `$scheme` if required.

If we don't trigger a redirect, then the given location block will simply proxy through to the upstream as usual.

```
http {
	server_name proxyforward;

	listen 80;
	listen 443 ssl;

    ssl_certificate      ../ssl/localssl.crt;
    ssl_certificate_key  ../ssl/localssl.key;

    init_by_lua '
        require "squtil.misc"
        require "squtil.regex"
        require "squtil.actions"
        require "squtil.memcache"
    ';

	upstream hosts-http { server upstream:80; }
	upstream hosts-https { server upstream:443; }

	location / {
	    rewrite_by_lua '
	        local authed = squtil.regex.match_all({
	            [[string-1-to-find-in-session]],
	            [[string-2-to-find-in-session]]
	        },squtil.memcache.get("127.0.0.1",11211,squtil.misc.get_cookie("authentication_cookie")))

	        if (authed and ngx.var.scheme == "http") or (not authed and ngx.var.scheme == "https") then
	            squtil.actions.redirect_flip_scheme()
	        end
	    ';

	    proxy_pass $scheme://hosts-$scheme;
	}
}
```

## TODO
* More functions :) 
* Clean up the misc.lua or find a better home for these functions

## Author

Ben Agricola <bagricola@squiz.co.uk>

## Licence

This module is licensed under the 2-clause BSD license.

Copyright (c) 2012, Ben Agricola <bagricola@squiz.co.uk>

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
