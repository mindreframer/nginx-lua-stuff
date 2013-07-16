-- handles all the authentication, don't touch me
-- skip favicon
local block = ""


if ngx.var.uri == "/favicon.ico" then return ngx.location.capture(ngx.var.uri) end
ngx.log(ngx.INFO, block, "################################################################################")

-- import requirements
local cjson = require("cjson")
local https = require("ssl.https")
local url = require("socket.url")
local ltn12 = require("ltn12")

local function pt(t)
  s = ""
  for k,v in pairs(t) do s=s.."("..k..","..v.."), " end
  ngx.log(ngx.INFO, block, s)
end

-- TODO: make this an oauth lib
-- note that org names are case-sensitive
local oauth = {
    app_id = "MY_GITHUB_APP_ID",
    app_secret = "MY_GITHUB_APP_SECRET",
    orgs_whitelist = {["MY_GITHUB_ORG"]=true},

    scope = "repo,user,user:email",
    authorize_base_url = "https://github.com/login/oauth/authorize",
    access_token_url = "https://github.com/login/oauth/access_token",
    user_orgs_url = "https://api.github.com/user/orgs",
}

oauth.authorize_url = oauth.authorize_base_url.."?client_id="..oauth.app_id.."&scope="..oauth.scope

function oauth.request(url_string, method)
    local result_table = {}

    local url_table = {
      url = url.build(url.parse(url_string, {port = 443})),
      method = method,
      sink = ltn12.sink.table(result_table),
      headers = {
        ["accept"] = "application/json"
      }
    }

    local body, code, headers, status_line = https.request(url_table)

    local json_body = ""
    for i, value in ipairs(result_table) do json_body = json_body .. value end

    ngx.log(ngx.INFO, block, "body::", json_body)

    return {body=cjson.decode(json_body), status=code, headers=headers}
end

function oauth.get(url_string)
    return oauth.request(url_string, "GET")
end

function oauth.get_access_token(code)

    local params = {
        access_token_url=oauth.access_token_url,
        client_id=oauth.app_id,
        client_secret=oauth.app_secret,
        code=code,
        redirect_uri=oauth.redirect_uri,
    }

    local url_string = oauth.access_token_url.."?"..ngx.encode_args(params)

    return oauth.get(url_string)
end


function oauth.verify_user(access_token)
    local params = {access_token=access_token}
    local url_string = oauth.user_orgs_url.."?"..ngx.encode_args(params)
    local response = oauth.get(url_string)
    local body = response.body

    if body.error then
        return {status=401, message=body.error}
    end

    for i, org in ipairs(body) do
        ngx.log(ngx.INFO, block, "testing", org.login)

        if oauth.orgs_whitelist[org.login] then
            ngx.log(ngx.INFO, block, org.login, " is in orgs_whitelist")
            return {status=200, body={access_token=access_token, org=org, access_level=9001}}
        end
    end

    return {status=403, message='not authorized for any orgs'}
end

--- end oauth lib


local args = ngx.req.get_uri_args()
local cookie_jar = {}


local function set_cookies(cookie_jar)
  local vals={}
  for k,v in pairs(cookie_jar) do table.insert(vals,v) end
  ngx.header["Set-Cookie"] = vals
end

local function del_cookie(c, cookie_jar)
  cookie_jar[c] = c.."=deleted; path=/; Expires=Thu, 01-Jan-1970 00:00:01 GMT"
  set_cookies(cookie_jar)
end

local function set_cookie(c, v, cookie_jar, age)
  age = age or 3000
  cookie_jar[c] = c.."="..v.."; path=/;Max-Age="..age
  set_cookies(cookie_jar)
end


-- extract previous token from cookie if it is there
local access_token = ngx.var.cookie_NGAccessToken or nil
local authorized = ngx.var.cookie_NGAuthorized or nil
local redirect_back = ngx.var.cookie_NGRedirectBack or ngx.var.uri
redirect_back = (string.match(redirect_back, "/_callback%??.*")) and "/" or redirect_back
ngx.log(ngx.INFO, block, "redirect_back0=", redirect_back)

if access_token == "" then access_token = nil end
if authorized ~= "true" then authorized = nil end

if access_token then set_cookie('NGAccessToken', access_token, cookie_jar) end
if authorized then set_cookie('NGAuthorized', authorized, cookie_jar) end
if redirect_back then set_cookie('NGRedirectBack', redirect_back, cookie_jar, 120) end

-- We have nothing, do it all
if authorized ~= "true" or not access_token then
    block = "[A]"
    ngx.log(ngx.INFO, block, 'authorized=', authorized)
    ngx.log(ngx.INFO, block, 'access_token=', access_token)

    -- first lets check for a code where we retrieve
    -- credentials from the api
    if not access_token or args.code then
        if args.code then
            response = oauth.get_access_token(args.code)

            -- kill all invalid responses immediately
            if response.status ~= 200 or response.body.error then
                ngx.status = response.status
                ngx.header["Content-Type"] = "application/json"
                response.body.auth_wall = "something went wrong with the OAuth process"
                ngx.say(cjson.encode(response.body))
                ngx.exit(ngx.HTTP_OK)
            end

            -- decode the token
            access_token = response.body.access_token
        end

        -- both the cookie and proxy_pass token retrieval failed
        if not access_token then
            ngx.log(ngx.INFO, block, 'no access_token')

            -- Redirect to the /oauth endpoint, request access to ALL scopes
            set_cookies(cookie_jar)
            return ngx.redirect(oauth.authorize_url)
        end
    end
end


if authorized ~= "true" then
    block = "[B]"
    ngx.log(ngx.INFO, block, 'authorized=', authorized)
    ngx.log(ngx.INFO, block, 'access_token=', access_token)
    -- ensure we have a user with the proper access app-level
    local verify_user_response = oauth.verify_user(access_token)
    if verify_user_response.status ~= 200 then
        -- delete their bad token
        del_cookie('NGAccessToken', cookie_jar)

        -- Redirect 403 forbidden back to the oauth endpoint, as their stored token was somehow bad
        if verify_user_response.status == 403 then
            set_cookies(cookie_jar)
            return ngx.redirect(oauth.authorize_url)
        end

        -- Disallow access
        ngx.status = verify_user_response.status
        ngx.say('{"status": 503, "message": "Error accessing oauth.api for credentials"}')

        set_cookies(cookie_jar)
        return ngx.exit(ngx.HTTP_OK)
    end

    -- Ensure we have the minimum for access_level to this resource
    if verify_user_response.body.access_level < 255 then
        -- Expire their stored token
        del_cookie('NGAccessToken', cookie_jar)
        del_cookie('NGAuthorized', cookie_jar)

        -- Disallow access
        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.say('{"status": 403, "message": "USER_ID "'..access_token..'" has no access to this resource"}')

        return ngx.exit(ngx.HTTP_OK)
    end

    -- Store the access_token within a cookie
    set_cookie('NGAccessToken', access_token, cookie_jar)
    set_cookie('NGAuthorized', "true", cookie_jar)
end

-- should be authorized by now

-- Support redirection back to your request if necessary
ngx.log(ngx.INFO, block, "redirect_back1=", redirect_back)
local redirect_back = ngx.var.cookie_NGRedirectBack
ngx.log(ngx.INFO, block, "redirect_back2=", redirect_back)

if redirect_back then
    ngx.log(ngx.INFO, block, "redirect_back3=", redirect_back)
    del_cookie('NGRedirectBack', cookie_jar)
    return ngx.redirect(redirect_back)
end
ngx.log(ngx.INFO, block, "--------------------------------------------------------------------------------")

-- Set some headers for use within the protected endpoint
-- ngx.req.set_header("X-USER-ACCESS-LEVEL", json.access_level)
-- ngx.req.set_header("X-USER-EMAIL", json.email)