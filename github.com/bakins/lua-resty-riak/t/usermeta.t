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

=== TEST 1: simple user metdatdata using raw interface
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
            local object = { key = "1", content = { value = "test", content_type = "text/plain", usermeta = { { key = "foo", value = "bar" } } } }
            local rc, err = client:store_object("test", object)
            ngx.say(rc)
            local object, err = client:get_object("test", "1")
            if not object then
                ngx.say(err)
            else
                ngx.say(object.content[1].value)
                ngx.say(type(object.content[1].usermeta))
		ngx.say(object.content[1].usermeta[1].value)
            end
	    local rc, err = client:delete_object("test", "1")
            ngx.say(rc)
            client:close()
        ';
    }
--- request
GET /t
--- response_body
true
test
table
bar
true
--- no_error_log
[error]

=== TEST 2: Usermetadata using high level client
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
	    object.meta.foo = "bar"
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
		ngx.say(type(object.meta))
		ngx.say(object.meta.foo)
            end
            local rc, err = object:delete()
            ngx.say(rc)
            client:close()
        ';
    }
--- request
GET /t
--- response_body
true
test
table
bar
true
--- no_error_log
[error]
