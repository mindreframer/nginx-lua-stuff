--
-- application configuration
--
-- var in this file can be got by "yagami.util.get_config(key)"
--

debug={
    on=false,
    to="response", -- "ngx.log"
}


mysql_set01 = {
	master= "127.0.0.1",
	masterport= 3306,
	slave="127.0.0.1",
	slaveport="3307",
}

-- redis cluster  
redis_set01 = {
	master= "127.0.0.1",
	masterport=6379,
	slave="127.0.0.1:6379 127.0.0.1:6379 127.0.0.1:6379",
	timeout=3000,
}

redis_set02 = {
	master= "127.0.0.1",
	masterport="6379",
	slave="127.0.0.1:6380 slave02:6381 slave03:6383",
	timeout="3000",
}

-------------------

redis_stat = {
	master= "127.0.0.1",
	masterport="3306",
	slave="127.0.0.1:6380",
}


logger = {
    file = "nginx_runtime/logs/yagamiko.log",
    level = "DEBUG",
}

config={
    templates="templates",
    
}

ip = {
	ip="/source/freeflare/server/yagamiko/conf/ip/qqwry.dat",	
}


weedfs = {
	master = "http://127.0.0.1:9333/dir/assign",
	volume = "http://127.0.0.1:9331/",
	tmplocal = "/tmp/fscache/freeflare/upload/",
}


subapps={
    -- subapp_name = {path="/path/to/another/yagamiapp", config={}},
}


