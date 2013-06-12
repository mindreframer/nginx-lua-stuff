local spawn = ngx.thread.spawn
local wait = ngx.thread.wait
local say = ngx.say
local sprintf = string.format
local print = ngx.print
local cjson = require 'cjson'
local feedparser = require 'feedparser'
local gsub, strfind, strformat, strsub = string.gsub, string.find, string.format, string.sub
local db = require 'dbutil'

-- Set the content type
ngx.header.content_type = 'application/json';

--
-- The function tha runs the subrequest to nginx and fetches the content
--
local function fetch(url, feed)
    --ngx.log(ngx.ERR, 'Fetching URL:'..url)
    local lastmodified = ngx.http_time(tonumber(feed.lastmodified))
    local res, err = ngx.location.capture('/fetcher/', { args = { url = url, lastmodified = lastmodified } })
    return res, err, feed
end

local function save(feed, parsed)
    if not feed then return end
    if not parsed then say('FUCKUP WITH PARSING') return  end
    local quote = dbutil.escapePostgresParam
    local rss_feed = feed.id
    -- save parsed values to rss_feed
    local title = quote(parsed.feed.title)
    local author = quote(parsed.feed.author)
    local url = quote(parsed.feed.link)

    db.dbreq(sprintf('UPDATE rss_feed SET title=%s, author=%s, url=%s, lastmodified=CURRENT_TIMESTAMP WHERE id=%s', title, author, url, rss_feed))


    -- insert entries
    for i, e in ipairs(parsed.entries) do
        local guid = e.guid
        if not guid then guid = e.link end
        local content = e.content
        if not content then content = e.summary end
        -- use postgresql "upsert" using writable CTE (psql 9.1 feature)
        local sql = [[
WITH new_values (rss_feed, guid, title, url, pubDate, content) AS (
  VALUES 
     ]]..sprintf('(%s, %s, %s, %s, %s::timestamp, %s)', rss_feed, quote(guid), quote(e.title), quote(e.link), quote(e.updated), quote(content))..[[
),
upsert as
( 
    UPDATE rss_item m 
        SET rss_feed = nv.rss_feed,
            guid = nv.guid,
            title = nv.title,
            url = nv.url,
            pubDate = nv.pubDate,
            content = nv.content
    FROM new_values nv
    WHERE m.rss_feed = nv.rss_feed
    AND m.guid = nv.guid
    RETURNING m.*
)
INSERT INTO rss_item (rss_feed, guid, title, url, pubDate, content)
SELECT rss_feed, guid, title, url, pubDate, content
FROM new_values
WHERE NOT EXISTS (SELECT 1 
                  FROM upsert up 
                  WHERE up.rss_feed = new_values.rss_feed
                  AND up.guid = new_values.guid)
]]
        local res = db.dbreq(sql)
    end
    return true
end

local function parse(feed, body)
    local parsed = feedparser.parse(body)
    if not parsed then
        say(feed.id..':: nil from feedparser!')
    else
        say(feed.id..':: '..#parsed.entries..' entries parsed.')
        if save(feed, parsed) then
            return 'Parse successful'
        else 
            return 'FUCKUP WITH SAVING'
        end
    end
end

local function wait_and_parse(threads)
    local newthreads = {}
    for i = 1, #threads do
        local ok, res, err, feed = wait(threads[i])
        if not ok then
            say(feed.id, ":failed to run: ", res)
        else
            say(feed.id, ":"..": status: ", res.status..', URL::'..feed.rssurl)
            if res.status >= 200 and res.status < 300 then
                say(feed.id, ":"..": parsed: ", parse(feed, res.body))
            elseif res.status == 304 then
                -- TODO handle if modified since
                say(feed.id, ':: Not modified since! Keep on truckin!')
            elseif res.status >= 300 and res.status < 304 then
                -- Got a redirect, spawn a new thread to fetch it
                table.insert(newthreads, spawn(fetch, res.header['Location'], feed))
                say(feed.id, ":"..feed.rssurl..": header: ", cjson.encode(res.header))
            else 
                say(feed.id, ":"..feed.rssurl..": header: ", cjson.encode(res.header))
            end
        end
    end
    return newthreads
end

local function refresh_feeds(feeds)

    local threads = {}

    for i, k in ipairs(feeds) do
        local url = k.rssurl;
        local match = ngx.re.match(url, '^https?://([0-9a-zA-Z-_\\.]+)/(.*)$', 'oj')
        if not match then
            ngx.log(ngx.ERR, 'Parser: No match for url:'..url)
        end
        -- FIXME port https
        local host = match[1]..':80'
        local path = match[2]
        url = 'http://' .. host .. '/' .. path
        table.insert(threads, spawn(fetch, url, k))
    end
    -- recursive resolving of threads
    while #threads > 0 do
        threads = wait_and_parse(threads)
    end
end

local function get_feeds()
    local res = db.dbreq("select id, rssurl, COALESCE(extract(epoch from lastmodified),0) as lastmodified from rss_feed");
    refresh_feeds(res)
end

local function get_missing_feeds()
    local res = db.dbreq("select id, rssurl, COALESCE(extract(epoch from lastmodified),0) as lastmodified from rss_feed where title IS NULL");
    refresh_feeds(res)
end

local function get_feed(match)
    local id = assert(tonumber(match[1]))
    local res = db.dbreq(sprintf('SELECT id, rssurl, COALESCE(extract(epoch from lastmodified),0) as lastmodified FROM rss_feed WHERE id = %s', id))
    refresh_feeds(res)
end

-- mapping patterns to views
local routes = {
    ['$']       = get_feeds,
    ['missing$'] = get_missing_feeds,
    ['(\\d+)$'] = get_feed,
}
-- Set the content type
ngx.header.content_type = 'application/json';

local BASE = '/crawl/'
-- iterate route patterns and find view
for pattern, view in pairs(routes) do
    local uri = '^' .. BASE .. pattern
    local match = ngx.re.match(ngx.var.uri, uri, "") -- regex mather in compile mode
    if match then
        exit = view(match) or ngx.HTTP_OK
        -- finish up
        ngx.exit( exit )
    end
end
-- no match, return 404
ngx.exit( ngx.HTTP_NOT_FOUND )
