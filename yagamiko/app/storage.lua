#!/usr/bin/env lua

module("storage", package.seeall)

local util = require("yagami.util")
local http = require("resty.http")
local JSON = require("cjson")
local uuid = require("resty.uuid")
local upload = require("resty.upload")




function savetoweedfs(req,resp)
    --add volidate
    --
    logger:d("storage request started!")

    -- doo check md5 of the file 

    local id 
    local chunk_size = 4096
    local form = upload:new(chunk_size)

    --change the header
    resp.headers['Content-Type'] = 'application/json'

    local weedfsurl = util.get_config('weedfs')
    
    if weedfsurl == nil then
        local info = 'weedfs master url is empty.'  
        ngx.log(ngx.ERR,info)
        return 400,info
    end

    local hc = http:new()

    local ok,code,headers,status,body = hc:request {
            url = weedfsurl.master,
            method = "GET",
            timeout = 1000,
    }


    if code == 200 then 
       local ret = JSON.decode(body)
       id = ret.fid
    else
        ngx.exit(500)
    end
    
    local file_name = weedfsurl.tmplocal..uuid:gen8()
    
    local file
    local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()    
    local chunk_size = 4096

    while true do
        local typ, res, err = form:read()
        if not typ then
             ngx.say("failed to read: ", err)
             return
        end
        if typ == "header" then
            if file_name then
                file = io.open(file_name, "w+")
                if not file then
                    ngx.say("failed to open file ", file_name)
                    return
                end
            end
         elseif typ == "body" then
            if file then
                file:write(res)
                --write data to hdfs or other 

                md5:update(res)
            end
        elseif typ == "part_end" then
            file:close()
            file = nil
            local md5sum = md5:final()
            md5:reset()
            ngx.status = 200

            -- save to resty 
            local cmd = 'curl -F file=@'..file_name..' '..weedfsurl.volume..id
            local ic = io.popen(cmd)
            local ret = ic:read("*all")
            
            --store to db 
            local str = require "resty.string"
            local md5str = str.to_hex(md5sum)
            -- @todo: must change the return method
            -- store info to the entity.
            --local retArr = JSON.decode(ret)
            --util.table_print(retArr)

            ngx.say(id..'    '..ret..'    md5:'..md5str)
            -- clear temp file by crontab job
            --os.execute('rm -rf '..file_name)

        elseif typ == "eof" then
            break
        else

        end

    end


end

--need to remove
function del()
    local id = req.uri_args['id']
    local weedfsurl = util.get_config('weedfs')
    if weedfsurl == nil then
        local info = 'weedfs volumn url is empty.'  
        return 404,info
    end
    local delUrl = weedfsurl.volume..id
    logger:d('delimageurl:'..delUrl)
    local hc = http:new()
    local ok,code,headers,status,body = hc:request {
            url = delUrl,
            method = "DELETE",
            timeout = 1000,
    }
    if code == 200 then 
        return 200,body
    else
        return 404,body
    end
end
