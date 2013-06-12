---
-- Persona Lua auth backend using ngx location capture
-- also using postgresql capture for storing sessions to db
-- 
-- Copyright Tor Hveem <thveem> 2013
-- 
-- Nginx conf example:
-- location /persona/ {
--     internal;
--     proxy_set_header Content-type 'application/json';
--     proxy_pass 'https://verifier.login.persona.org:443/verify';
-- }
--
local setmetatable = setmetatable
local ngx = ngx
local cjson = require "cjson"
local db = require 'dbutil'
local sprintf = string.format

module(...)

local mt = { __index = _M }

function verify(assertion, audience)

    local vars = {
        assertion=assertion,
        audience=audience,
    }
    local options = {
        method = ngx.HTTP_POST,
        body = cjson.encode(vars)
    }

    local res, err = ngx.location.capture('/persona/', options);

    if not res then
        return { err = res }
    end

    if res.status >= 200 and res.status < 300 then
        return cjson.decode(res.body)
    else
        return {
            status= res.status,
            body = res.body
        }
    end
end

function getsess(sessionid)
    local res = db.dbreq("SELECT * FROM session WHERE sessionid = '"..sessionid.."'")
    if res then 
        return res[1]
    end
    return nil
end

local function setsess(personadata)
    -- Set cookie for session
    local sessionid = ngx.md5(personadata.email .. ngx.md5(personadata.expires))
    ngx.header['Set-Cookie'] = 'session='..sessionid..'; path=/; HttpOnly'
    -- TODO Expire the key when the session expires, so if key exists login is valid
    -- FIXME login counter ? with CTE upsert?
    local sql = db.dbreq('INSERT INTO email (email) VALUES ('..db.quote(personadata.email)..')')
    local sql = db.dbreq(sprintf('INSERT INTO session (sessionid, email, created, expires) VALUES (%s, %s, CURRENT_TIMESTAMP, to_timestamp(%s))', db.quote(sessionid), db.quote(personadata.email), db.quote(personadata.expires)))
end

function get_current_email()
    local cookie = ngx.var['cookie_session']
    if cookie then
        local sess = getsess(cookie)
        if sess then
            return sess.email
        end
    end
    return false
end

function login()
    ngx.req.read_body()
    -- app is sending application/json
    local body = ngx.req.get_body_data()
    if body then 
        local args = cjson.decode(body)
        local audience = 'nyfyk.hveem.no'
        local personadata = verify(args.assertion, audience)
        if personadata.status == 'okay' then
            setsess(personadata)
        end
        -- Print the data back to client
        ngx.print(cjson.encode(personadata))
    else
        ngx.print ( cjson.encode({ email = false}) )
    end
end

function status()
    local cookie = ngx.var['cookie_session']
    if cookie then
        ngx.print ( cjson.encode(getsess(cookie)) )
    else
        ngx.print ( '{"email":false}' )
    end
end

function logout()
    local cookie = ngx.var['cookie_session']
    if cookie then
        local sql = db.dbreq("DELETE FROM session WHERE sessionid = '"..cookie.."'")
        ngx.print( 'true' )
    else
        ngx.print( 'false' )
    end
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        ngx.log(ngx.ERR, 'attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
