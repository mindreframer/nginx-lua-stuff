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

=== TEST 1: put and get using raw client
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
	    local object = { key = "1", content = { value = "test", content_type = "text/plain" }} 
	    local rc, err = client:store_object("test", object)
            ngx.say(rc)
            local object, err = client:get_object("test", "1")
            if not object then
                ngx.say(err)
            else
                ngx.say(object.content[1].value)
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
