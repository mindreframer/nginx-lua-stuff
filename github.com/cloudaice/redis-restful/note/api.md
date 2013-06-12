local appid = 
{
    'default',
    'appid',
}

local res_type =
{
    'key',
    'redis',
    'cmd'
}
local get_urilist = 
{
    'appid/key/{keyid}/del',
    'appid/keys/randomkey',
    'appid/key/{keyid}/ttl',
    'appid/key/{keyid}/pttl',
    'appid/key/{keyid}/exists',
    'appid/key/{keyid}/type',
    'appid/key/{keyid}/get',
    'appid/key/{keyid}/mget', 
    'appid/key/{keyid}/getrange?start=&end=',
    'appid/key/{keyid}/strlen', 
    'appid/key/{keyid}/getbit?offset=', 
    'appid/key/{keyid}/bitcount?start=&end=', 
    'appid/key/{keyid}/field/{fieldid}/hget', 
    'appid/key/{keyid}/hgetall',
    'appid/key/{keyid}/field/{fieldid}/hdel',
    'appid/key/{keyid}/hlen',
    'appid/key/{keyid}/field/[fieldid]/hexists',
    'appid/key/{keyid}/hkeys',
    'appid/key/{keyid}/hvals',
    'appid/key/{keyid}/llen',
    'appid/key/{keyid}/lrange?start=&stop=',
    'appid/key/{keyid}/lindex?index=',
    'appid/key/{keyid}/smembers',
    'appid/key/{keyid}/sismember?member=',
    'appid/key/{keyid}/scard',
    'appid/key/{keyid}/srandmember?count=',
    'appid/key/{keyid}/zcard',
    'appid/key/{keyid}/zcount?min=&max=',
    'appid/key/{keyid}/member/{memberid}/zscore',
    'appid/key/{keyid}/member/{memberid}/zscore',
    'appid/key/{keyid}/zrange?start=&end=&withscores=',
    'appid/key/{keyid}/zrevrange?start=&end=&withscores=',
    'appid/key/{keyid}/member/{memberid}/zrank',
    'appid/key/{keyid}/member/{memberid}/zrevrank',
}

local post_urilist =
{
    'appid/key/del', post_data = {key0, key1...}
    'appid/key/{keyid}/rename', post_data = { newkey }
    'appid/key/{keyid}/renamenx', post_data = { newkey }
    'appid/key/{keyid}/expire', post_data = { seconds }
    'appid/key/{keyid}/pexpire', post_data = { milliseconds }
    'appid/key/{keyid}/expireat', post_data = { timestamp }
    'appid/key/{keyid}/pexpireat', post_data = { milliseconds timestamp }
    'appid/key/{keyid}/persist', post_data = {}
    'appid/key/{keyid}/dump', post_data = {}
    'appid/key/{keyid}/restore', post_data = {ttl, serialized-value}
    'appid/key/{keyid}/set', post_data = { value }
    'appid/key/{keyid}/setnx', post_data = { value }
    'appid/key/{keyid}/setex', post_data = { seconds, value }
    'appid/key/{keyid}/psetex', post_data = { milliseconds, value }
    'appid/key/{keyid}/setrange', post_data = { offset, value }
    'appid/keys/mset', post_data = { key, value, key, value, ... }
    'appid/keys/msetnx', post_data = { key, value, key, value, ... }
    'appid/key/{keyid}/append', post_data = { value }
    'appid/key/{keyid}/getset', post_data = { value }
    'appid/key/{keyid}/decr', post_data = {}
    'appid/key/{keyid}/decrby', post_data = { decrement }
    'appid/key/{keyid}/incr', post_data = {}
    'appid/key/{keyid}/incrby', post_data = { increment }
    'appid/key/{keyid}/incrbyfloat', post_data = { increment }
    'appid/key/{keyid}/setbit', post_data = { offset, value }
    'appid/key/{keyid}/bitop', post_data = { operation, destkey, key0, key1, ... }
    'appid/key/{keyid}/hset', post_data = { field, value }
    'appid/key/{keyid}/hsetnx', post_data = { field, value }
    'appid/key/{keyid}/hmset', post_data = { field, value, field, value, ... }
    'appid/key/{keyid}/hmget', post_data = { field0, field1, ...}
    'appid/key/{keyid}/hdel', post_data = { field0, field1, ...}
    'appid/key/{keyid}/field/{fieldid}/hincrby', post_data = { increment }
    'appid/key/{keyid}/field/{fieldid}/hincrbyfloat', post_data = { increment }
    'appid/key/{keyid}/lpush', post_data = { value0, value1, ... }
    'appid/key/{keyid}/lpushx', post_data = { value }
    'appid/key/{keyid}/rpush', post_data = { value0, value1, ... }
    'appid/key/{keyid}/rpushx', post_data = { value }
    'appid/key/{keyid}/lpop', post_data = {}
    'appid/key/{keyid}/rpop', post_data = {}
    'appid/key/{keyid}/blpop', post_data = {key0, key1, ..., timeout}
    'appid/key/{keyid}/brpop', post_data = {key0, key1, ..., timeout}
    'appid/key/{keyid}/lrem', post_data = { count, value }
    'appid/key/{keyid}/lset', post_data = { index, value }
    'appid/key/{keyid}/ltrim', post_data = { start, stop }
    'appid/key/{keyid}/linsert', post_data = { before|after, pivot, value }
    'appid/key/{keyid}/sadd', post_data = { member0, member1, ... }
    'appid/key/{keyid}/srem', post_data = { member0, member1, ... }
    'appid/key/{keyid}/spop', post_data = {}
    'appid/key/{keyid}/sinter', post_data = { key0, key1, ...}
    'appid/key/{keyid}/sunion', post_data = { key0, key1, ...}
    'appid/key/{keyid}/sdiff', post_data = { key0, key1, ...}
    'appid/key/{keyid}/zadd', post_data = { score0, key0, score1, key1, ...}
    'appid/key/{keyid}/zrem', post_data = { member0, member1, ... }
    'appid/key/{keyid}/member/{memberid}/zincrby', post_data = { increment }
    'appid/key/{keyid}/zremrangebyrank', post_data = { start, stop }
    'appid/key/{keyid}/zremrangebyscore', post_data = { start, stop }
}

for i = 1, #post_urilist do
    print (post_urilist[i])
end
