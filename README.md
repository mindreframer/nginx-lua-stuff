# FakeNGX #

FakeNGX is an initial attempt to create a library for testing Lua scripts
embedded into Nginx, via [HttpLuaModule](http://wiki.nginx.org/HttpLuaModule)

## Features ##

* Support for basic constants: ngx.HTTP_OK, etc
* Support for core functions: ngx.time(...), ngx.encode_args(...), etc
* Sub-request stubbing, e.g. ngx.location.capture()
* Fully tested with [Telescope](http://norman.github.com/telescope/)

## Supported functions (currently) ##

* ngx.print()
* ngx.say()
* ngx.log()
* ngx.time()
* ngx.now()
* ngx.exit()
* ngx.escape_uri()
* ngx.unescape_uri()
* ngx.encode_args()
* ngx.crc32_short()
* ngx.location.capture()

## Usage Example ##

This is an example for how to test your scripts with FakeNGX. Imagine this is
your Nginx configuration:

    -- nginx.conf
    location /internal {
      internal;
      content_by_lua 'ngx.print("OK")';
    }

    location /main {
      content_by_lua_file 'main.lua';
    }

It's good practice to keep file loaded by
[content_by_lua_file](http://wiki.nginx.org/HttpLuaModule#content_by_lua_file)
at a minimum and place all processing logic into external modules. This allows
[lua_code_cache](http://wiki.nginx.org/HttpLuaModule#lua_code_cache)
to work its magic and simplifies your testing. For example:

    -- main.lua
    local my_module = require 'my_module'
    my_module.run()

Then, place all the controller code into separate module(s):

    -- my_module.lua
    module("my_module", package.seeall)

    local function respond()
      local res = ngx.location.capture("/internal", { method = ngx.HTTP_POST })

      if res.status == ngx.HTTP_OK then
        ngx.print(res.body)
      else
        ngx.print("ERR")
        ngx.exit(500)
      end
    end

    function run()
      if ngx.var.http_authentication == "TOKEN"
        respond()
      else
        ngx.exit(403)
      end
    end

    return my_module

In your tests e.g. with [Telescope](http://norman.github.com/telescope/):

    fakengx   = require 'fakengx'
    my_module = require 'my_module'

    context('my_module', function()

      before(function()
        ngx = fakengx.new() -- create a fresh ngx on each request context
      end)

      test('run unauthenticated', function()
        my_module.run()
        assert_equal(ngx._body, '')   -- No output
        assert_equal(ngx._exit, 403)  -- Exited with 403
        assert_equal(ngx.status, 403) -- Response status
      end)

      test('run success', function()
        ngx.location.stub('/internal', {}, { body = "OK" })
        ngx.var['http_authentication' = "TOKEN"
        my_module.run()
        assert_equal(ngx._body, 'OK') -- Written "OK"
        assert_nil(ngx._exit)         -- No explicit exit
        assert_equal(ngx.status, 200) -- Response status
      end)

      test('run failure', function()
        ngx.location.stub('/internal', {}, { status = 302 })
        my_module.run()
        assert_equal(ngx._body, 'ERR')
        assert_equal(ngx._exit, 500)
        assert_equal(ngx.status, 500)
      end)

    end)

## Prerequsites ##

FakeNGX relies on the [luasocket](http://w3.impa.br/~diego/software/luasocket/)
and the [bitop](http://bitop.luajit.org/) libraries.

To install (on Debian, Ubuntu, etc):

    sudo apt-get install lua5.1 luarocks liblua5.1-socket2 liblua5.1-bitop0 liblua5.1-md5-0

## Contributing ##

You need to install telescope, via LuaRocks:

    sudo luarocks install telescope

And run:

    tsc -f spec/*_spec.lua


## License ##

The MIT License

Copyright (c) 2012 Dimitrij Denissenko

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
