#; -*- mode: perl;-*-

use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * blocks() * 3;

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_NGINX_RIAK_PORT} ||= 8087;

no_long_string();

run_tests();

__DATA__

=== TEST 1: simple 2i
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local riak = require "resty.riak.client"
            local client = riak.new()
            local ok, err = client:connect("127.0.0.1", 8087)
            if not ok then
                ngx.log(ngx.ERR, "connect failed: " .. err)
            end
            local object = { key = "1", content = { value = "test", content_type = "text/plain", indexes = { { key = "foo_bin", value = "bar"} } } }
            local rc, err = client:store_object("test", object)
            ngx.say(rc)
            local object, err = client:get_object("test", "1")
            if not object then
                ngx.say(err)
            else
                ngx.say(object.content[1].value)
            end
            local keys = client:get_index("test", "foo_bin", "bar")
            ngx.say(type(keys[1]))

            -- index miss
            keys = client:get_index("test", "foo_bin", "this should not be found")
            ngx.say(type(keys[1]))

            client:close()
        ';
    }
--- request
GET /t
--- response_body
true
test
string
nil
--- no_error_log
[error]

=== TEST 2: 2i using highlevel interface
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
            object.indexes.foo_bin = "bar"
            local rc, err = object:store()
            ngx.say(rc)
            if not rc then
                ngx.say(err)
            end
            local keys, err = bucket:index("foo_bin", "bar")
            if not keys then
                ngx.say(err)
            end
            ngx.say(type(keys[1]))

            -- index miss
            local keys, err = bucket:index("foo_bin", "this should not be found")
            if not keys then
                ngx.say(err)
            end
            ngx.say(type(keys[1]))
            client:close()
        ';
    }
--- request
GET /t
--- response_body
true
string
nil
--- no_error_log
[error]
