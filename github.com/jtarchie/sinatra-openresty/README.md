# Introduction

I'm a fan of the Ruby library [Sinatra](http://sinatrarb.com). It provides a great DSL to map HTTP requests to build APIs, websites, or just simple wrappers around already working code.


# Getting Started

```sh
git clone https://github.com/jtarchie/sinatra-openresty.git
cd sinatra-openresty
```

Take a look at the example application under `examples/app.lua`.

# TODO
* look into using standard request and response objects ([WSAPI](https://github.com/keplerproject/wsapi) or [Rack](https://github.com/pintsized/lua-resty-rack))
* Provide example application that uses JSON and database
* Optimize route callback (should I be using coroutines or pcall)
* Write documentation for supported functionality


# Test

Assuming that you already have OpenResty installed, `nginx` is available via
PATH, and you've added [moonrocks](http://rocks.moonscript.org/about).

```sh
luarocks install sinatra-dev-1.rockspec
busted 
```
