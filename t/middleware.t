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

=== TEST 1: basic middleware test
--- http_config eval: $::HttpConfig
--- config
    location /t {
        rewrite /t(.*) $1 break;
        content_by_lua '
            return require("middleware").run(ngx)
        ';
    }
--- request
GET /t/awesome
--- response_body
/AWESOME
--- no_error_log
[error]

