# nginx-json-proxy

Ever wanted make sure you're only passing JSON across a boundary? Every
thought the best place to do this would be in Lua embedded in nginx?
This project is for you.

## Usage

You can test out the example by running nginx via foreman:

    bundle exec foreman start

Then making requests via curl:

    # valid JSON
    curl -X POST -d '["bob", "jim"]' http://localhost:3000/
    ["bob","jim"]

    # invalid JSON
    curl -X POST -d '["bob", "jim]' http://localhost:3000/
    invalid request

Rather than use a real backend the example currently just hard codes the
response. If you change the text on line 11 of request.lua to return
invalid JSON (say `ngx.say('["bob","jim]')` then you should get:

    # valid JSON, with invalid JSON response
    curl -X POST -d '["bob", "jim"]' http://localhost:3000/
    invalid response

## Installing OpenResty in the ./vendor folder 
    
    bundle
    bundle exec rake openresty:install
    bundle exec foreman start nginx

### On Debian/Ubuntu

    apt-get install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl

### On OSX
    
    brew install pcre

## Thanks

Thanks to Tommy Hall and his [nginx-lua-examples](https://github.com/thattommyhall/nginx-lua-examples) for the Rakefile and Procfile which made getting started easier.
