--- "Low level" riak client. Just a thin wrapper over the "raw" protocol buffers.
-- This API may change and should not be considered stable. It may change between major versions.
-- While not "private", just be aware it may change. Only the high-level API is considered stable.
-- @module resty.riak.client

local require = require
local setmetatable = setmetatable
local error = error
local ngx = ngx
local type = type

local helpers = require("resty.riak.helpers")

local _M = helpers.module()

local pb = require "pb"
local struct = require "struct"
local riak = pb.require "riak"
local riak_kv = pb.require "riak_kv"

local spack, sunpack = struct.pack, struct.unpack

local ErrorResp = riak.RpbErrorResp()

local function encode_message(encoder, request)
    if request then
	local msg = encoder(request)
	local bin, errmsg = msg:Serialize()
	if not bin then
	    return nil, "serialization failed: " .. errmsg
	else
	    return bin, nil
	end
    else
	return "", nil
    end
end

local function parse_error(response)
    local errmsg = ErrorResp:Parse(response)
    if errmsg and 'table' == type(errmsg) then
	if errmsg['errmsg'] then
	    response = errmsg['errmsg']
	else
	    response = 'error'
	end
    end
    return nil, response
end
	
local function send_request(sock, msgcode, encoder, request)
    local bin, err = encode_message(encoder, request)
    
    if not bin then
	return nil, err
    end
    
    local info = spack(">IB", #bin + 1, msgcode)
    
    local bytes, err = sock:send(info .. bin)
    if not bytes then
        return nil, err
    end
    local bytes, err, partial = sock:receive(5)
    if not bytes then
        return nil, err
    end
    
    local length, msgcode = sunpack(">IB", bytes)
    
    bytes = length - 1
    local response = nil
    if bytes > 0 then 
        response, err = sock:receive(bytes)
        if not response then
            return nil, err
        end
    end
    
    if msgcode == 0 then
	return parse_error(response)
    else
	return msgcode, response
    end
end
    
--- Creates a riak object.
-- @treturn riak.resty.client "low level" client object
function _M.new()
    local sock, err = ngx.socket.tcp()
    if not sock then
        return nil, err
    end
    local self = {
        sock = sock
    }
    return setmetatable(self, { __index = _M })
end

-- Generic socket functions

--- Sets the timeout protection for subsequent operations, including the `connect` method.
-- @tparam resty.riak.client self
-- @tparam number timeout in milliseconds
function _M.set_timeout(self, timeout)
    return self.sock:settimeout(timeout)
end

--- Attempts to connect to the remote host and port.
-- Before actually resolving the host name and connecting to the remote backend, 
-- this method will always look up the connection pool for matched idle connections 
-- created by previous calls of this method.
-- @tparam resty.riak.client self
-- @tparam string host see [tcpsock:connect](http://wiki.nginx.org/HttpLuaModule#tcpsock:connect)
-- @tparam number port see [tcpsock:connect](http://wiki.nginx.org/HttpLuaModule#tcpsock:connect)
-- @treturn boolean not true on error
-- @treturn string error description
function _M.connect(self, ...)
    return self.sock:connect(...)
end

--- Keeps the current riak connection alive and put it into the ngx_lua cosocket connection pool.
-- You can specify the max idle timeout when the connection is in the pool and the maximal size of the pool every nginx worker process.
-- @tparam resty.riak.client self
-- @tparam number timeout in milliseconds see [tcpsock:setkeepalive](http://wiki.nginx.org/HttpLuaModule#tcpsock:setkeepalive)
-- @tparam number size the maximal number of connections allowed in the connection pool for the current server. see [tcpsock:setkeepalive](http://wiki.nginx.org/HttpLuaModule#tcpsock:setkeepalive)
-- @treturn boolean not true on error
-- @treturn string error description
function _M.set_keepalive(self, ...)
    return self.sock:setkeepalive(...)
end

-- This method returns the (successfully) reused times for the current connection. 
-- If the current connection does not come from the built-in connection pool, then this method always returns `0`, that is, the connection has never been reused (yet). If the connection comes from the connection pool, then the return value is always non-zero. So this method can also be used to determine if the current connection comes from the pool.
-- @tparam resty.riak.client self
-- @treturn number times the connection has been used
function _M.get_reused_times(self)
    return self.sock:getreusedtimes()
end

-- Closes the riak connection
-- @tparam resty.riak.client self
-- @treturn boolean not true on error
-- @treturn string error description
function _M.close(self)
    return self.sock:close()
end

local function handle_request_response(sock, request_msgcode, encoder, request, response_msgcode, handler)
    local msgcode, response = send_request(sock, request_msgcode, encoder, request)
    if not msgcode then
        return nil, response
    end

    if msgcode == response_msgcode then
	return handler(response)
    else
	return nil, "unhandled response type"
    end
end

local PutReq = riak_kv.RpbPutReq
local function true_handler(response)
    return true
end
--- Store a "raw" riak object. The definition of a riak object is defined
-- in the riak PBC as [RpbContent](http://docs.basho.com/riak/latest/references/apis/protocol-buffers/PBC-Fetch-Object/).
-- @tparam resty.riak.client self
-- @tparam string bucket
-- @tparam table object in the form of RpbContent
-- @treturn boolean not true on error
-- @treturn string error description
-- @usage
-- local object = { key = "1", content = { value = "test", content_type = "text/plain" } }
-- local rc, err = client:store_object("bucket-name", object)
-- -- if using eleveldb, secondary indexes can be added to object before storing
-- local object = { key = "1", content = { { value = "test", content_type = "text/plain", indexes = { { key = "foo_bin", value = "bar" } } } }}
function _M.store_object(self, bucket, object)
    object.bucket = bucket
    return handle_request_response(self.sock, 11, PutReq, object, 12, true_handler)
end

local DelReq = riak_kv.RpbDelReq
--- Delete an object.
-- @tparam resty.riak.client self
-- @tparam string bucket
-- @tparam string key
-- @treturn boolean not true on error. If an object does not exist and there is no other error (network, time out, etc) then this will still return true.
-- @treturn string error description
function _M.delete_object(self, bucket, key)
    local sock = self.sock
    
    local request = { 
        bucket = bucket, 
        key = key 
    }
    
    -- 13 = DelReq
    -- 14 = DelResp
    return handle_request_response(sock, 13, DelReq, request, 14, true_handler)
end

local GetReq = riak_kv.RpbGetReq
local GetResp = riak_kv.RpbGetResp()
local function get_handler(response)
    if not response or response.deleted then
	return nil, "not found"
    end
    return GetResp:Parse(response)
end

--- Retrieve an object.
-- @tparam resty.riak.client self
-- @tparam string bucket
-- @tparam string key
-- @treturn table [RpbContent](http://docs.basho.com/riak/latest/references/apis/protocol-buffers/PBC-Fetch-Object/).  If not found, then `nil`. 
-- @treturn string error description.   If not found, `not found` will be returned.
function _M.get_object(self, bucket, key)
    local sock = self.sock
    local request = {
        bucket = bucket,
        key = key
    }
    -- 9 = GetReq
    -- 10 = GetResp
    return handle_request_response(sock, 9, GetReq, request, 10, get_handler)
end

--- "Ping" the riak server.
-- @tparam resty.riak.client self
-- @treturn boolean not true on error.
-- @treturn string error description
function _M.ping(self)
    -- 1 = PingReq
    -- 2 - PingResp
    return handle_request_response(self.sock, 1, nil, nil, 2, true_handler)
end

local GetClientIdResp = riak_kv.RpbGetClientIdResp()
local function client_id_handler(response)
    return GetClientIdResp:Parse(response).client_id, nil
end
--- Retrieve client id.
-- @tparam resty.riak.client self
-- @treturn string id
-- @treturn string error description
function _M.get_client_id(self)
    -- 3 = GetClientIdReq
    -- 4 = GetClientIdResp
    return handle_request_response(self.sock, 3, nil, nil, 4, client_id_handler)
end

local GetServerInfoResp = riak.RpbGetServerInfoResp()
local function server_info_handler(response)
    return GetServerInfoResp:Parse(response), nil
end
--- "Ping" the riak server.
-- @tparam resty.riak.client self
-- @treturn table info as defined in [RpbGetServerInfoResp](http://docs.basho.com/riak/latest/references/apis/protocol-buffers/PBC-Server-Info/#Response)
-- @treturn string error description
function _M.get_server_info(self)
    -- 7 = GetClientIdReq
    -- 8 = GetServerInfoResp
    return handle_request_response(self.sock, 7, nil, nil, 8, server_info_handler)
end

local GetBucketReq = riak.RpbGetBucketReq
local GetBucketResp = riak.RpbGetBucketResp()
local function bucket_props_handler(response)
    return GetBucketResp:Parse(response).props, nil
end
--- Get bucket properties
-- @tparam resty.riak.client self
-- @tparam string bucket
-- @treturn table properties as defined in [RpbBucketProps](http://docs.basho.com/riak/latest/references/apis/protocol-buffers/PBC-Get-Bucket-Properties/#Response)
-- @treturn string error description
function _M.get_bucket_props(self, bucket)
    local request = {
        bucket = bucket
    }
    -- 19 = GetBucketReq
    -- 20 = GetBucketResp
    return handle_request_response(self.sock, 19, GetBucketReq, request, 20, bucket_props_handler)
end

local IndexReq = riak_kv.RpbIndexReq
local IndexResp = riak_kv.RpbIndexResp()
local function index_handler(response)
    if response then
	return IndexResp:Parse(response).keys, nil
    else
	return {}
    end
end

--- Query a secondary index
-- @tparam resty.riak.client self
-- @tparam string bucket
-- @tparam string index
-- @param value If this is a string, this is an exact match query, if a table then it is a range query
function _M.get_index(self, bucket, index, value)
    -- IndexQueryType: eq = 0, range = 1
    local qtype = ("table" == type(value)) and 1 or 0

    local request = {
	bucket = bucket,
	index = index,
	qtype = qtype
    }
    if 0 == qtype then
	request.key = value
    else
	request.range_min = value[1]
	request.range_max = value[2]
    end
    -- 25 = RpbIndexReq
    -- 26 = RpbIndexResp
    return handle_request_response(self.sock, 25, IndexReq, request, 26, index_handler)
end

return _M
