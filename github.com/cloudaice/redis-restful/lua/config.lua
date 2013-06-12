--file config.lua
--@author: xiangchao<cloudaice@gmail.com>

module(...)

servers =
{
    {
        name='server1',
        host='127.0.0.1',
        port=6380,
        db=0
    },
    {
        name='server2',
        host='127.0.0.1',
        port=6379,
        db=0
    }
}

-- 应用名称
apps = 
{ 
    'default'
}

-- 访问的类型，有针对key的，也有针对keys的，后续会增加redis。
types = 
{
    'key',
    'keys'
}

patterns = 
{
    '^/%w+/key/[^/]+/%w+$',
    '^/%w+/keys/%w+$',
    '^/%w+/key/[^/]+/field/[^/]+/%w+$',
    '^/%w+/key/[^/]+/member/[^/]+/%w+$'
}

commands = {
    --[[ key ]]                         
    -- 删除一个或者多个key
    del = {
        { 
            method = 'POST',
            args_len = 1,
            args = {
                {
                name = 'keys', 
                sepatate = true
                }
            }
        },
        {
            method = 'GET',
            args_len = 0, 
            args = {
                name = nil,
                sepatate = false
            }
        }
    },
    renamenx = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'newkey',
                    separate = false
                }
            }
        }
    },
    exists = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                name = nil,
                separate = false
                }
            }
        }
    }, 
    expire = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'seconds',
                    separate = false
                }
            }
        }
    },       
    pexpire = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'milliseconds',
                    separate = false
                }
            }
        }
    },
    randomkey = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    sepatate = false
                }
            }
        }
    },
    ttl = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }

        }
    },   
    pttl = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    sepatate = false
                }
            }
        }
    },
    expireat = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'timestamp',
                    separate = false
                }
            }
        }
    }, 
    pexpireat = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'milliseconds_timestamp',
                    separate = false
                }
            }
        }
    },
    persist = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    rename = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'newkey',
                    separate = false
                }
            }
        }
    },     
    type = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    dump = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    restore = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'ttl',
                    separate = false
                },
                {
                    name = 'serialized-value',
                    separate = false
                }
            }
        }
    },
    
    --[[string]]          
    append = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    getbit = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'offset',
                    separate = false
                }
            }
        }
    },
    mget = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    setex = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'seconds',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    psetex = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'milliseconds',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    getrange = {
        {
            method = 'GET',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'end',
                    separate = false
                }
            }
        }
    },
    mset = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'key-values',
                    separate = true
                }
            }
        }
    },
    setnx = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    getset = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    msetnx = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'key-value',
                    separate = true
                }
            }
        }
    },
    setrange = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'offset',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    decr = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    incr = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    strlen = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    decrby = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'decrement',
                    separate = false
                }
            }
        }
    },
    incrby = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'increment',
                    separate = false
                }
            }
        }
    },
    incrbyfloat = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'increment',
                    separate = false
                }
            }
        }
    },
    set = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    get = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    setbit = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'offset',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    bitop = {
        {
            method = 'POST',
            args_len = 3,
            args = {
                {
                    name = 'operation',
                    separate = false
                },
                {
                    name = 'destkey',
                    separate = false
                },
                {
                    name = 'keys',
                    separate = true
                }
            }
        }
    },
    bitcount = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                },
            }
        },
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'end',
                    separate = false
                }
            }
        }
    },
    
    --[[sets]]     
    sadd ={
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        },
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'keys',
                    separate = true
                }
            }
        }
    },
    sinter ={
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'members',
                    separate = true
                }
            }
        }
    },
    sunion ={
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'keys',
                    separate = true
                }
            }
        }
    },
    scard ={
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    spop ={
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    sdiff ={
        {
            method = 'GET',
            args_len = 1,
            args = {
                {
                    name = 'keys',
                    separate = true
                }
            }
        }
    },
    sismember ={
        {
            method = 'GET',
            args_len = 1,
            args = {
                {
                    name = 'member',
                    separate = false
                }
            }
        }
    },
    srandmember ={
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        },
        {
            method = 'GET',
            args_len = 1,
            args = {
                {
                    name = 'count',
                    separate = false
                }
            }
        }
    },
    smembers ={
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    srem ={
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'members',
                    separate = true
                }
            }
        }
    },
    
    --[[hash]]
    hdel = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'fields',
                    separate = true
                }
            }
        }
    },
    hincrby = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'increment',
                    separate = false
                }
            }
        }
    },
    hincrbyfloat = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'increment',
                    separate = false
                }
            }
        }
    },
    hmget = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'fields',
                    separate = true
                }
            }
        }
    },
    hvals = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    hexists = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    hmset = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'field-values',
                    separate = true
                }
            }
        }
    },
    hget = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    hkeys = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    hset = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'key',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    hgetall = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    hlen = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    hsetnx = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'key',
                    separate = false
                },
                {
                    name = 'value',
                    separate =false
                }
            }
        }
    },
    
    --[[sorted sets]]   
    zadd = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'score-member',
                    separate = true
                }
            }
        }
    },
    zrem = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'members',
                    separate = true
                }
            }
        }
    },
    zrevrangebyscore = {
        {
            method = 'GET',
            args_len = 2,
            args = {
                {
                    name = 'min',
                    separate = false
                },
                {
                    name = 'max',
                    separate = false
                }
            }
        }
    },
    zcard = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    zrange = {
        {
            method = 'GET',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'end',
                    separate = false
                }
            }
        },
        {
            method = 'GET',
            args_len = 3,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'end',
                    separate = false
                },
                {
                    name = 'withscores',
                    separate = false
                }
            }
        }
    },
    zremrangebyrank = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'stop',
                    separate = false
                }
            }
        }
    },
    zrevrank = {
        {
            method = 'GET',
            args_len = 1,
            args = {
                {
                    name = 'member',
                    separate = false
                }
            }
        }
    },
    zcount = {
        {
            method = 'GET',
            args_len = 2,
            args = {
                {
                    name = 'min',
                    separate = false
                },
                {
                    name = 'max',
                    separate = false
                }
            }
        }
    },
    zremrangebyscore = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'stop',
                    separate = false
                }
            }
        }
    },
    zscore = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    zincrby = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'increment',
                    separate = false
                }
            }
        }
    },
    zrank = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    zrevrange = {
        {
            method = 'GET',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'end',
                    separate = false
                }
            }
        },
        {
            method = 'GET',
            args_len = 3,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'end',
                    separate = false
                },
                {
                    name = 'withscores',
                    separate = false
                }
            }

        }
    },
    
    --[[list]]    
    blpop = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'keys',
                    separate = true
                },
                {
                    name = 'timeout',
                    separate = false
                }
            }
        }
    },
    llen = {
        {
            method = 'GET',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    rpush = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'keys',
                    separate = true
                }
            }
        }
    },
    brpop = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'keys',
                    separate = true
                },
                {
                    name = 'timeout',
                    separate = false
                }
            }
        }
    },
    lpop = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    lset = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'index',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    rpushx = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    lpush = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'keys',
                    separate = true
                }
            }
        }
    },
    ltrim = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'stop',
                    separate = false
                }
            }
        }
    },
    lindex = {
        {
            method = 'GET',
            args_len = 1,
            args = {
                {
                    name = 'index',
                    separate = false
                }
            }
        }
    },
    lpushx = {
        {
            method = 'POST',
            args_len = 1,
            args = {
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    rpop = {
        {
            method = 'POST',
            args_len = 0,
            args = {
                {
                    name = nil,
                    separate = false
                }
            }
        }
    },
    linsert = {
        {
            method = 'POST',
            args_len = 3,
            args = {
                {
                    name = 'position',
                    separate = false
                },
                {
                    name = 'pivot',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    },
    lrange = {
        {
            method = 'GET',
            args_len = 2,
            args = {
                {
                    name = 'start',
                    separate = false
                },
                {
                    name = 'stop',
                    separate = false
                }
            }
        }
    },
    lrem = {
        {
            method = 'POST',
            args_len = 2,
            args = {
                {
                    name = 'count',
                    separate = false
                },
                {
                    name = 'value',
                    separate = false
                }
            }
        }
    } 
}

local function _print() 
    for a, b in pairs(commands) do
        print (a)
    end
end
