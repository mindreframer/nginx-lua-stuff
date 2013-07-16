--- Riak bucket. Can only be used with @{resty.riak} created client
-- @see resty.riak
-- @module resty.riak.bucket
-- @alias _M

local require = require
local setmetatable = setmetatable
local error = error

local _M = require("resty.riak.helpers").module()

local riak_object = require "resty.riak.object"
local riak_client = require "resty.riak.client"

local riak_object_new = riak_object.new

--- Create a new riak value object. this can also be called as `bucket:new(key)`
-- @tparam resty.riak.bucket self
-- @tparam string key 
-- @treturn resty.riak.object
-- @see resty.riak.object.new
function _M.new_object(self, key)
    return riak_object_new(self, key)
end

local new_object = _M.new_object

--- Create a new bucket object. This does not actually do anything to riak. It only sets up the Lua objects
-- @tparam resty.riak client a resy.riak created client
-- @tparam string name the name of the bucket
-- @treturn resty.riak.bucket a riak bucket object
function _M.new(client, name)
    local self = {
        name = name, 
        client = client, 
	new = new_object
    }
    return setmetatable(self, { __index = _M })
end

local riak_client_get_object = riak_client.get_object
local riak_object_load = riak_object.load
--- Get a riak object
-- @tparam resty.riak.bucket self
-- @tparam string key
-- @treturn resty.riak.object `nil` if not found
-- @treturn error description. `not found` if not found
-- @see resty.riak.client.get_object
function _M.get(self, key)
    local object, err = riak_client_get_object(self.client, self.name, key)
    if object then
	return riak_object_load(self, key, object)
    else
	return nil, err
    end
end

--- Get a riak object or create one if it does not exist
-- @tparam resty.riak.bucket self
-- @tparam string key
-- @treturn resty.riak.object 
-- @treturn error description.
-- @see new_object
-- @see get
function _M.get_or_new(self, key)
    local object, err = riak_client_get_object(self.client, self.name, key)
    if not object then
	if "not found" == err then
	    return riak_object_new(self, key)
	else
	    return nil, err
	end
    else
	return riak_object_load(object)
    end
end

local riak_client_delete_object = riak_client.delete_object
--- Delete an object
-- @tparam resty.riak.bucket self
-- @tparam string key
-- @see resty.riak.client.delete_object
function _M.delete(self, key)
    return riak_client_delete_object(self.client, self.name, key)
end

local riak_client_get_index = riak_client.get_index
-- Query a secondary index
-- @tparam resty.riak.bucket self
-- @tparam string bucket
-- @tparam string index
-- @param value If this is a string, this is an exact match query, if a table then it is a range query
function _M.index(self, index, value)
    return riak_client_get_index(self.client, self.name, index, value)
end

local get_bucket_props = riak_client.get_bucket_props
--- Get bucket properties
-- @tparam resty.riak.bucket self
-- @tparam string bucket
-- @treturn table properties as defined in [RpbBucketProps](http://docs.basho.com/riak/latest/references/apis/protocol-buffers/PBC-Get-Bucket-Properties/#Response)
-- @treturn string error description
function _M.properties(self)
    return get_bucket_props(self.client, self.name)
end


return _M
