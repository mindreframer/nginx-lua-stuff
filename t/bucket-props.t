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

=== TEST 1: get bucket props
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
	    local object = { key = "1", value = "test", content_type = "text/plain" } 
	    local rc, err = client:store_object("test", object)
	    local props, err = client:get_bucket_props("test")
	    ngx.say(type(props))
	    ngx.say(type(props.n_val))
	    ngx.say(type(props.allow_mult))
            client:close()
        ';
    }
--- request
GET /t
--- response_body
table
number
number
--- no_error_log
[error]

=== TEST 2: get bucket props using high level interface
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
	    local props, err = bucket:properties("test")
	    ngx.say(type(props))
	    ngx.say(type(props.n_val))
	    ngx.say(type(props.allow_mult))
            client:close()
        ';
    }
--- request
GET /t
--- response_body
table
number
number
--- no_error_log
[error]
