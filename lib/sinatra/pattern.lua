local table = table
local Pattern, Utils = {}, require("sinatra/utils")
Pattern.__index = Pattern

local function compile_pattern(pattern)
  local keys = {}
  local compiled_pattern = pattern:gsub("[^%w%?\\/:*]", function(c)
    return Utils.escape(c):gsub('%%(%x)(%x)', function(a,b)
      return '%%[' .. a:upper() .. a:lower() .. '][' .. b:upper() .. b:lower() .. ']'
    end)
  end):gsub(":([%w]+)", function(match)
    table.insert(keys, match)
    return '([^/?#]+)'
  end):gsub("%*", function(match)
    table.insert(keys, "splat")
    return "(.-)"
  end)
  return({
    original=pattern,
    matcher='^' .. compiled_pattern .. '$',
    keys=keys
  })
end

function Pattern:new(pattern)
  local self = setmetatable(compile_pattern(pattern), Pattern)
  return self
end

function Pattern:match(path)
  return string.match(path, self.matcher)
end

return Pattern
