Redis-Restful
=============

对redis的restful接口包装
-----------------

+ 使用restful接口访问和调用redis 
+ 便于控制对redis访问
+ 规范化对redis统一操作
+ 增强对redis的可控制性


uri
---

     应用名称  类型       命令
        |       |         |
    /{appid}/{types}/.../{cmd}

Server Config
-------------

    servers =
    {
        {   
            name = 'server1',
            host = '127.0.0.1',
            port = '6379',
            db = 0
        },
        {
            name = 'server2',
            host = '127.0.0.1',
            port = '6380',
            db = 0
        }
    } 

Command Config
-------------

    commands = {
        cmd0 = {
            {
                method = '',
                args_len = '',
                args = {
                    { 
                        name = 
                        separate = 
                    }
                    ...
                }
            }
            ...
        }
        cmd1 = {
    
        }
        ...
    }

TODO
----

+ check config file
+ append test case
+ make diffrent appid to diffrent instance
+ add check head module
+ auth action
+ ...

Usage
-----

    mkdir mywork
    git clone git@github.com:cloudaice/redis-restful.git

修改`openresty.server`里面配置路径

  + DAEMON: 设置nginx可执行文件路径
  + CONF: 设置nginx配置文件路径
  + PID: 设置nginx进程的pid文件路径
  + ROOTPATH: 设置当前工作环境的路径，作为根路径

Note
----

本来是把请求的验证放在access阶段的，为了复用access阶段获得的一些变量，于是采用共享内存的方式,存入dict，后来发现这么做会导致不同的请求访问的时候造成变量污染，于是把验证和执行都放在了content阶段。
