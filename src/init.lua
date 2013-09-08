local dbmt = require ((...)..".dbmt" )

local socket = ngx.socket.tcp

local function parse_host(str)
  local host, port = str:match ( "([^:]+):?(%d*)" )
  if not port then port = 27017 end
  return host, port
end

local connmethods = {}
function connmethods:ismaster()
  local db = self:new_db_handle("admin")
  local r, err = db:cmd({ismaster = true})
  if not r then
    return nil, err
  end
  return r.ismaster, r.hosts
end

function connmethods:getprimary(searched)

  if not searched then
    searched = {
      [self.host .. ":" .. self.port] = true
    }
  end

  local db = self:new_db_handle("admin")

  local r, err = db:cmd({ ismaster = true })
  if not r then

    return nil, "query admin failed: "..err

  elseif r.ismaster then

    return self

  else

    for i, v in ipairs ( r.hosts ) do

      if not searched[v] then

        searched[v] = true
        local host, port = parse_host(v)
        local conn = new()

        local ok, err = conn:connect(host, port)
        if not ok then
          return nil, "connect failed: "..err..v
        end

        local found = conn:getprimary(searched)
        if found then
          return found
        end
      end
    end
  end

  return nil , "No master server found"
end

function connmethods:databases()
  local db = self:new_db_handle("admin")
  local r = assert(db:cmd({ listDatabases = true }))
  return r.databases
end

function connmethods:shutdown()
  local db = self:new_db_handle("admin")
  db:cmd({ shutdown = true } )
end

function connmethods:new_db_handle(db)
  if not db then
    return nil
  end

  return setmetatable({
    conn = self,
    db = db,
  },
  dbmt
  )
end

function connmethods:set_timeout(timeout)
  if not self.sock then
    return nil, "not initialized"
  end

  return self.sock:settimeout(timeout)
end

function connmethods:set_keepalive(...)
  if not self.sock then
    return nil, "not initialized"
  end

  return self.sock:setkeepalive(...)
end

function connmethods:get_reused_times()
  if not self.sock then
    return nil, "not initialized"
  end

  return self.sock:getreusedtimes()
end

function connmethods:connect(host, port)
  if host then self.host=host end
  if port then self.port=port end

  return self.sock:connect(self.host, self.port)
end

function connmethods:close()
  if not self.sock then
    return nil, "not initialized"
  end

  return self.sock:close()
end

function new(self)
  return setmetatable({
    sock = socket(),
    host = "localhost",
    port = 27017
  },
  {
    __call = connmethods.new_db_handle,
    __index = connmethods
  })
end

return setmetatable({}, {
  __newindex = function(table, key, val)
    error('attempt to write to undeclared variable "'..key..'": '..debug.traceback())
  end,
  __call = new
})
