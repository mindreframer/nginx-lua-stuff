Name
====

lua-resty-http - Lua http client driver for the lua based on the cosocket API.

support ngx_lua and alilua-coevent-module.

support HTTP/1.1 (keepalive, gzip, deflate, chunked transfer)

Status
======

This library is considered experimental and still under active development.

The API is still in flux and may change without notice.

Updates
======

2013-07-31 add https support

Synopsis
========

    local L = require('coevent')
    local httprequest = require('httpclient')

    L(function()
        -- download a page
        print(
            httprequest('http://example.com/')
        )
        
        -- download a page with _GET params
        print(
            httprequest('http://example.com/?key=value')
        )
        
        -- download a page with HTTP Base Auth
        print(
            httprequest('http://user:pw@example.com/')
        )
        
        -- POST datas to download a page
        print(
            httprequest('http://example.com/', {
                                            data = {
                                                key = 'value',
                                                key2 = 'value2',
                                            }
                                        })
        )
        
        -- Upload file
        ff = io.open('t.txt')
        print(
            httprequest('http://example.com/', {
                                        data = {
                                            field = 'value',
                                            file = {
                                                file = ff,
                                                name = 't.txt',
                                                type = 'text/plain'
                                            },
                                        }
                                        })
        )
        
        -- download a page with COOKIE
        print(
            httprequest('http://example.com', {
                header = 'Cookie: key=value;',
            })
        )
        
        print(
            httprequest('http://example.com', {
                header = {
                            'Cookie: key=value;',
                            'X: headerx',
                         },
            })
        )
        
        -- custom METHOD
        print(
            httprequest('http://example.com', {
                method = 'DELETE'
                }
            )
        )
        
        -- keepalive requests
        print(
            httprequest('http://example.com/' {
                    pool_size = 60, -- conection pool size
                }
            )
        )
    end
    )

