#!/usr/bin/env lua
package	= 'lua-stardust'
version	= 'scm-0'

source	= {
    url = 'git://github.com/bakins/stardust.git'
}

description    = {
    summary    = "Lua Stardust Web Application Framewok",
    detailed   = '',
    homepage   = 'https://github.com/bakins/stardust',
    license    = 'Apache2',
    maintainer = "Brian Akins",
}

dependencies = {
}

build = {
    type = "builtin",
    modules = {
	stardust = "lib/stardust.lua",
	["stardust.request"] = "lib/stardust/request.lua",
	["stardust.response"] = "lib/stardust/response.lua",
	["stardust.router"] = "lib/stardust/router.lua",
    }
}
