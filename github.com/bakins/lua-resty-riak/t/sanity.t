#; -*- mode: perl;-*-

use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);

#plan tests => repeat_each() * blocks();
plan tests => repeat_each() * blocks() * 3;

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;/usr/share/lua/5.1/?.lua;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_NGINX_RIAK_PORT} ||= 8087;

no_long_string();

run_tests();

__DATA__

=== TEST 1: put and get simple string
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
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
            if not rc then
                ngx.say(err)
            end  
            local object, err = bucket:get("1")
            if not object then
                ngx.say(err)
            else
                ngx.say(object.value)
            end
            client:close()
        ';
    }
--- request
GET /t
--- response_body
true
test
--- no_error_log
[error]

=== TEST 2: not found 
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local riak = require "resty.riak"
            local client = riak.new()
            local ok, err = client:connect("127.0.0.1", 8087)
            if not ok then
                ngx.log(ngx.ERR, "connect failed: " .. err)
            end
            local bucket = client:bucket("test")
            local object, err = bucket:get("something not there")
            if not object then
                ngx.say(err)
            else
                ngx.say(object.value)
            end
            client:close()
        ';
    }
--- request
GET /t
--- response_body
not found
--- no_error_log
[error]
