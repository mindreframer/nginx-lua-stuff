module("beenos", package.seeall)

function readAll(file)
  -- local f = io.open(file, "rb")
  local f = io.open(file, "rb")
  local content = f:read("*all")

  -- ngx.log(ngx.NOTICE, content)

  f:close()
  return content
end

function split(str, delim)
  -- Eliminate bad cases...
  if string.find(str, delim) == nil then
    return { str }
  end

  local result = {}
  local pat = "(.-)" .. delim .. "()"
  local lastPos
  for part, pos in string.gfind(str, pat) do
    table.insert(result, part)
    lastPos = pos
  end
  table.insert(result, string.sub(str, lastPos))
  return result
end

function set_value(shm, key, value)
  ngx.log(ngx.NOTICE, key .. " -> " .. value)
  shm:set(key, value)
end

function value_for_key(shm, key)

  local value = shm:get(key)

  value = value or "0"
  value = tonumber(value)

  return value
end

function increment_key(shm, key)

  -- ngx.log(ngx.NOTICE, "increment key -> " .. key)

  local newval, err = shm:incr(key, 1)

  if not newval and err == "not found" then
    shm:add(key, 0)
    shm:incr(key, 1)
  end
end
