use lib 'lib';
use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;$pwd/examples/?.lua;;";
};

no_long_string();

run_tests();

__DATA__

=== TEST 1: basic json test
--- http_config eval: $::HttpConfig
--- config
    location /t {
        rewrite /t(.*) $1 break;
        content_by_lua '
            return require("simple").run(ngx)
        ';
    }
--- request
GET /t/options
--- response_headers
Content-Type: application/json
--- no_error_log
[error]



=== TEST 2: basic html test
--- http_config eval: $::HttpConfig
--- config
    location /t {
        rewrite /t(.*) $1 break;
        content_by_lua '
            return require("simple").run(ngx)
        ';
    }
--- request
GET /t/foo.html
--- response_headers
Content-Type: text/html
--- no_error_log
[error]
