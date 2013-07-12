# Yagami Framework

This is a demo to how to use yagami and openresty to develop web app.

## 1、Install and Configuration

### 1.1 OpenResty install
URL：http://openresty.org/#Installation
compile luajit:
./configure --with-luajit --prefix=/usr/local 
if is max os X : 
brew install pcre
brew link --overwrite pcre
./configure --with-luajit --prefix=/usr/local --with-cc-opt="-I/usr/local/Cellar/pcre/8.32/include" --with-ld-opt="-L/usr/local/Cellar/pcre/8.32/lib"
make 
make install



### 1.2 Yagami Install
    #Checkout Yagami
    git clone git://github.com/xinqiyang/yagami.git 
    

### 1.3 Env Configuration
    #Set OpenResty Path
    export OPENRESTY_HOME=/usr/local
    
    #Set Yagami Path
    export YAGAMI_HOME=/path/to/yagami
    
    #avaliable Env Setting
    source ~/.bashrc
    
    #add above to  ~/.bashrc Or ~/.profile when next login,it will be auto setting.
    vim ~/.bashrc
    

## 2、Demo Code
### 2.1 Checkout example code
    git clone git://github.com/xinqiyang/yagami-demo.git
    cd yagami-demo
    
### 2.2 Source Tree
    
    yagami-demo #Root
    |
    |-- routing.lua # URL Routing Setting
    |-- application.lua # yagami app description file
    |
    |-- app #App Dir
    |   `-- test.lua #Logic File
    |
    |-- bin #Scripts Dir
    |   |-- debug.sh #Stop Service->clear error log->Start Service->Show error log
    |   |-- reload.sh #reload nginx
    |   |-- start.sh #Start
    |   |-- stop.sh #Stop
    |   |-- console.sh #yagami Console。Attendtion:yagami Console need to Python2.7 or Python3.2 support。
    |   `-- cut_nginx_log_daily.sh #Nginx log split scripts
    |
    |-- conf  #Configuration Dir
    |    `-- nginx.conf  #Nginx Setting file。Need to  `set $YAGAMI_APP_NAME 'yagami-demo';` You real app name。
    |
    |-- templates  #ltp template Dir
    |    `-- ltp.html  #ltp template file
    |
    |-- static  #Static (images,css,js)
    |    `-- main.js  #js File
    |
    |-- yagami_demo.log #Debug log file。 in application.lua set path and notice level。
    |
    `-- nginx_runtime #Nginx runtime dir。
        |-- conf
        |   `-- p-nginx.conf #Nginx  ./bin/start.sh build auto.
        |
        `-- logs #Nginx runtime log
            |-- access.log #Nginx Access log
            |-- error.log #Nginx error log
            `-- nginx.pid #Nginx process id file
    

### 2.3 Start/Stop/Reload/Debug Method
    ./bin/start.sh #Start
    ./bin/stop.sh #Stop
    ./bin/reload.sh #Reload
    ./bin/debug.sh #Stop Service->Clear error log->Start Service->show error log

Notice：those command must run in the Yagami root path  with  this `./bin/xxx.sh` style。    

### 2.4 Test
    curl "http://localhost:9800/hello?name=xxxxxxxx"
    curl "http://localhost:9800/ltp"
    tail -f yagami_demo.log #show log
    tail -f nginx_runtime/logs/access.log  #show Nginx visit log
    tail -f nginx_runtime/logs/error.log  #show Nginx error/debug log

### 2.5 yagami Console debug
    ./bin/console.sh #Open an console，input debug code to debug。Notice:yagami Console need to install Python2.7 Or Python3.2。

## 3、Dev Web App
### 3.1 URL Routing: routing.lua
    #!/usr/bin/env lua
    -- -*- lua -*-
    
    local router = require('yagami.router')
    router.setup()
    
    ---------------------------------------------------------------------
    
    map('^/hello%?name=(.*)',           'test.hello')
    
    ---------------------------------------------------------------------
    

### 3.2 Request process function：app/test.lua
Request recieve the 2 params，request And response，It is similar HTTP's request and response。

    #!/usr/bin/env lua
    -- -*- lua -*-
    --
    
    module("test", package.seeall)
    
    local JSON = require("cjson")
    local Redis = require("resty.redis")
    
    function hello(req, resp, name)
        if req.method=='GET' then
            -- resp:writeln('Host: ' .. req.host)
            -- resp:writeln('Hello, ' .. ngx.unescape_uri(name))
            -- resp:writeln('name, ' .. req.uri_args['name'])
            resp.headers['Content-Type'] = 'application/json'
            resp:writeln(JSON.encode(req.uri_args))

            resp:writeln({{'a','c',{'d','e', {'f','b'})
        elseif req.method=='POST' then
            -- resp:writeln('POST to Host: ' .. req.host)
            req:read_body()
            resp.headers['Content-Type'] = 'application/json'
            resp:writeln(JSON.encode(req.post_args))
        end 
    end

### 3.3 request Object's property and method
More infomation: http://wiki.nginx.org/HttpLuaModule and http://wiki.nginx.org/HttpCoreModule .

    --property
    method=ngx.var.request_method           -- http://wiki.nginx.org/HttpCoreModule#.24request_method
    schema=ngx.var.schema                   -- http://wiki.nginx.org/HttpCoreModule#.24scheme
    host=ngx.var.host                       -- http://wiki.nginx.org/HttpCoreModule#.24host
    hostname=ngx.var.hostname               -- http://wiki.nginx.org/HttpCoreModule#.24hostname
    uri=ngx.var.request_uri                 -- http://wiki.nginx.org/HttpCoreModule#.24request_uri
    path=ngx.var.uri                        -- http://wiki.nginx.org/HttpCoreModule#.24uri
    filename=ngx.var.request_filename       -- http://wiki.nginx.org/HttpCoreModule#.24request_filename
    query_string=ngx.var.query_string       -- http://wiki.nginx.org/HttpCoreModule#.24query_string
    user_agent=ngx.var.http_user_agent      -- http://wiki.nginx.org/HttpCoreModule#.24http_HEADER
    remote_addr=ngx.var.remote_addr         -- http://wiki.nginx.org/HttpCoreModule#.24remote_addr
    remote_port=ngx.var.remote_port         -- http://wiki.nginx.org/HttpCoreModule#.24remote_port
    remote_user=ngx.var.remote_user         -- http://wiki.nginx.org/HttpCoreModule#.24remote_user
    remote_passwd=ngx.var.remote_passwd     -- http://wiki.nginx.org/HttpCoreModule#.24remote_passwd
    content_type=ngx.var.content_type       -- http://wiki.nginx.org/HttpCoreModule#.24content_type
    content_length=ngx.var.content_length   -- http://wiki.nginx.org/HttpCoreModule#.24content_length
    
    headers=ngx.req.get_headers()           -- http://wiki.nginx.org/HttpLuaModule#ngx.req.get_headers
    uri_args=ngx.req.get_uri_args()         -- http://wiki.nginx.org/HttpLuaModule#ngx.req.get_uri_args
    post_args=ngx.req.get_post_args()       -- http://wiki.nginx.org/HttpLuaModule#ngx.req.get_post_args
    socket=ngx.req.socket                   -- http://wiki.nginx.org/HttpLuaModule#ngx.req.socket
    
    --Method
    request:read_body()                     -- http://wiki.nginx.org/HttpLuaModule#ngx.req.read_body
    request:get_uri_arg(name, default)
    request:get_post_arg(name, default)
    request:get_arg(name, default)

    request:get_cookie(key, decrypt)
    request:rewrite(uri, jump)              -- http://wiki.nginx.org/HttpLuaModule#ngx.req.set_uri
    request:set_uri_args(args)              -- http://wiki.nginx.org/HttpLuaModule#ngx.req.set_uri_args
    

### 3.4 response Object's property and method
    --Property
    headers=ngx.header                      -- http://wiki.nginx.org/HttpLuaModule#ngx.header.HEADER
    
    --Method
    response:set_cookie(key, value, encrypt, duration, path)
    response:write(content)
    response:writeln(content)
    response:ltp(template,data)
    response:redirect(url, status)          -- http://wiki.nginx.org/HttpLuaModule#ngx.redirect

    response:finish()                       -- http://wiki.nginx.org/HttpLuaModule#ngx.eof
    response:is_finished()
    response:defer(func, ...)               -- run behind response

### 3.5 print debug log
in `application.lua` define log file location and Level
    
    logger:i(format, ...)  -- INFO
    logger:d(format, ...)  -- DEBUG
    logger:w(format, ...)  -- WARN
    logger:e(format, ...)  -- ERROR
    logger:f(format, ...)  -- FATAL
    -- format 和string.format(s, ...) same to：http://www.lua.org/manual/5.1/manual.html#pdf-string.format

view log

    tail -f yagami_demo.log

view nginx error log

    tail -f nginx_runtime/logs/error.log  

### 3.6 Common Error
1. YAGAMI URL Mapping Error
1. Error while doing defers
1. Yagami ERROR

## 4、Multi-App 与 Sub-App

### 4.1 multi-app
    Multi yagami-app could run with one nginx process，if you copy  yagami-app more behind nginx.conf。

### 4.2 sub-app
    set yagami-app with sub of one app,set in master app's application.lua：

    subapps={
        subapp1 = {path="/path/to/subapp1", config={}},
        ...
    }


## 5 Reference
1. http://wiki.nginx.org/HttpLuaModule 
1. http://wiki.nginx.org/HttpCoreModule 
1. http://openresty.org
1. https://github.com/appwilldev/yagami

