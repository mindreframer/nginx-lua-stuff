# nginx-lua-examples
Based on the excellent work on [openresty-statsd](https://github.com/lonelyplanet/openresty-statsd) by the guys from Lonely Planet and a few examples from the nginx wiki page for [HttpLuaModule](http://wiki.nginx.org/HttpLuaModule) and [this](http://www.londonlua.org/scripting_nginx_with_lua/slides.html) excellent intro presentation from [@pintsized](http://twitter.com/pintsized)

## Installing OpenResty in the ./vendor folder 
(assuming you have ruby and understand bundler etc)
    
    bundle
    bundle exec rake openresty:install
    bundle exec foreman start nginx

## On Debian/Ubuntu

    apt-get install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl

## On OSX
    
    brew install pcre