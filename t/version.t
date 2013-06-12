#; -*- mode: perl;-*-

# based on version.t from https://github.com/agentzh/lua-resty-memcached

use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
lua_package_path "$pwd/lib/?.lua;/usr/share/lua/5.1/?.lua;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';

no_long_string();
#no_diff();

run_tests();

__DATA__

=== TEST 1: basic
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
local riak = require "resty.riak"
ngx.say(riak._VERSION)
';
    }
--- request
    GET /t
--- response_body_like chop
^\d+\.\d+\.\d+$
--- no_error_log
[error]
