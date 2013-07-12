Ziggy Stardust
==========

Ziggy Stardust (or just "stardust") is a simple nginx/Lua framework inspired by
[Sinatra](http://www.sinatrarb.com/),
[Express](http://expressjs.com/), and
[Mercury](https://github.com/nrk/mercury).

It is currently in development and is little more than a toy. It may
eat your data and crash your computer.

Sample
------
The easiest way to explain stardust is to show an example.

    local stardust = require "stardust"
    local router = require "stardust.router"
    
    local app = stardust.new()
    local r = router.new()
    app:use(r)
    
    r:get("%.txt?$",
        function(req, res)
            res.body = "hello, it seems you requested " .. req.path
        end
       )
       
    function _M.run(ngx)
        return app:run(ngx)
    end

    return _M
    
And the add something like this to your nginx virtual server config:

    location / {
        content_by_lua 'return require("redis").run(ngx)';
    }
    
There are more examples in the `examples` directory.


# Concepts Building Blocks #

The modules are documented using
[ldoc](http://stevedonovan.github.com/ldoc/). Check that for the
"real" documentation.

## Core ##
Lua module `stardust`

The core of stardust doesn't do much. It is used to create and run and
app. It is also used to register middleware for an app.

## Middleware ##
Middleware is where the actual work happens. Here's and extremely
simple example of creating and using middleware:

    
    local app = stardust.new()
    local r = router.new()
    app:use(r)
    
    app:use(function(req, res) 
        res.body = string.upper(res.body)
    end
    
    r:get("%.txt?$",
        function(req, res)
            res.body = "hello, it seems you requested " .. req.path
        end
       )
       
 In this example, the body of the response will be converted to
 uppercase. The middleware can live in a module or be created "on the
 fly" -- stardust doesn't care, it just needs to be a function that
 accepts a request and a response. Middleware should generally return
 `nil` . (Still figuring out when/how we want middleware to be able to
 halt the request/response both for failure and success.)
 
 In case you didn't notice, the router is just middleware. Middleware
 is ran in the order it is registered using the `use` method.
 
## Router ##
 Lua module `stardust.router`
 
 The router is fairly simple and currently uses Lua string patterns to
 match routes. The routes are ran in order and the first match wins.
 
## Request ##
Lua module `stardust.request`

A request is generally read-only and is a thin wrapper around an HTTP
request as used by nginx.   See the modules docs for the "fields."

## Response ##
Lua module `stardust.response`

Basically a table that has fields:

* status - HTTP status code. defaults to 200
* headers - Lua table of HTTP response headers
* body - table or string of the actual response body

All of these are read/write.


