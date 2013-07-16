package = "lua-resty-riak"
version = "1.0.0-1"
source = {
    url = "git://github.com/bakins/lua-resty-riak.git"
}
description = {
    summary = "ngx_lua Riak protocol buffer client",
    homepage = "https://github.com/bakins/lua-resty-riak",
    license = "BSD"
}
dependencies = {
    "lpack",
    "lua-pb"
}
build = {
    type = "builtin",
    install = {
	lua = { 'lib/riak.proto', 'lib/riak_kv.proto' }
    },
    modules = {
	['resty.riak'] = "lib/resty/riak.lua",
	['resty.riak.bucket'] = "lib/resty/riak/bucket.lua",
	['resty.riak.object'] = "lib/resty/riak/object.lua",
	['resty.riak.client'] = "lib/resty/riak/client.lua",
	['resty.riak.helpers'] = "lib/resty/riak/helpers.lua"
    }
}
