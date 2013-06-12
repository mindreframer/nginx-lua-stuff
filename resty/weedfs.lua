--
-- Created by IntelliJ IDEA.
-- User: Medcl
-- Date: 12-9-15
-- Time: 上午11:14
--
-----------------------------------------------------------------------------
-- WeedFS
-- Author: Medcl
-- RCS ID: $Id: weedfs.lua,v 1.0.0 2012/09/15 11:20:00
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Declare module
-----------------------------------------------------------------------------
local string = require("string")
local url = require("resty")
module("resty.weedfs", package.seeall)

-----------------------------------------------------------------------------
-- Module version
-----------------------------------------------------------------------------
_VERSION = "URL 1.0.0"


function escape(s)
    return string.gsub(s, "([^A-Za-z0-9_])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
end