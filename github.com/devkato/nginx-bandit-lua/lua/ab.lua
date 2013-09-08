
local common = require 'common'
local bandit = require 'bandit'
local results = {}

function replaced_data(candidate, algorithm, num)

  local template_num = 0

  if algorithm == 'random' then

    math.randomseed(os.clock())
    template_num = math.floor(math.random(num))
  elseif algorithm == 'epsilon' then

    template_num = bandit.select_arm_with_epsilon(num)
  elseif algorithm == 'softmax' then

    template_num = bandit.select_arm_with_softmax()
  elseif algorithm == 'ucb' then

    template_num = bandit.select_arm_with_ucb()
  end

  -- ngx.log(ngx.NOTICE, candidate .. ".template_num : ", template_num)

  local file_path = "/Users/kato/nginx_lua/candidates/" .. candidate .. "/" .. template_num .. ".html"
  -- ngx.log(ngx.NOTICE, "file_path : ", file_path)

  local key = candidate .. ":pv:" .. template_num
  local total_key = candidate .. ":pv:total"

  common.increment_key(ngx.shared.beacons, key)
  common.increment_key(ngx.shared.beacons, total_key)

  local html = common.readAll(file_path)

  results[candidate] = template_num

  return html
end

ngx.arg[1] = string.gsub(ngx.arg[1], "%{%{([%w_]+):([%w_]+):(%d+)%}%}", replaced_data)

--
-- for debug
--
result_out = "<!--\n"

for key, template_num in pairs(results) do
  result_out = result_out .. key .. " : " .. template_num .. "\n"
end

result_out = result_out .. "-->"

ngx.arg[1] = ngx.arg[1] .. result_out

