module("bandit", package.seeall)

local common = require("common")

function select_arm_with_epsilon(num_candidates)

  math.randomseed(os.clock())

  local epsilon = 0.7--0.3
  local threshold = math.random()

  -- ngx.log(ngx.NOTICE, "threshold -> " .. threshold)

  if threshold > epsilon then
    
    local n_arms = 4
    local values = {}

    for i = 1, n_arms do
      local value = common.value_for_key(ngx.shared.beacons, "test2:weight:" .. i)
      values[i] = value

      -- ngx.log(ngx.NOTICE, "value[" .. i .. "] -> " .. value)
    end

    return ind_max(values)
  else
    return math.floor(math.random(num_candidates))
  end
end

function temperature()
  local value = common.value_for_key(ngx.shared.beacons, "softmax:temperature")

  if value == 0 then
    return 100.0
  else
    return value
  end
end

function categorical_draw(probs)

  math.randomseed(os.clock())

  local z = math.random()
  local cum_prob = 0.000001

  for i, value in pairs(probs) do
    cum_prob = cum_prob + value

    if cum_prob > z then
      return i
    end
  end

  return table.getn(probs)
end

function select_arm_with_softmax()

  local n_arms = 4
  local z = 0.0

  for i = 1, n_arms do
    local value = common.value_for_key(ngx.shared.beacons, "test2:weight:" .. i)

    z = z + math.exp(value / temperature())
  end

  ngx.log(ngx.NOTICE, "z -> " .. z)

  local probs = {}

  for i = 1, n_arms do
    local value = common.value_for_key(ngx.shared.beacons, "test2:weight:" .. i)
    probs[i] = math.exp(value / temperature()) / z
  end

  return categorical_draw(probs)
end

function select_arm_with_ucb()

  local n_arms = 4

  for i = 1, n_arms do
    local count = common.value_for_key(ngx.shared.beacons, "test2:click:" .. i)

    if count == 0 then
      ngx.log(ngx.NOTICE, "count is 0!")
      return i
    end
  end

  local ucb_values = {}

  for i = 1, n_arms do
    ucb_values[i] = 0.0
  end

  local total_counts = common.value_for_key(ngx.shared.beacons, "test2:click:total")

  for i = 1, n_arms do
    local count = common.value_for_key(ngx.shared.beacons, "test2:click:" .. i)
    local value = common.value_for_key(ngx.shared.beacons, "test2:weight:" .. i)
    local bonus = math.sqrt((2.0 * math.log(total_counts)) / count)

    ngx.log(ngx.NOTICE, "value -> " .. value .. ", bonus -> " .. bonus)

    ucb_values[i] = value + bonus + 0.00001
  end

  return ind_max(ucb_values)
end

function update(chosen_arm, reward)

  local n = common.value_for_key(ngx.shared.beacons, "test2:click:" .. chosen_arm)
  local value = common.value_for_key(ngx.shared.beacons, "test2:weight:" .. chosen_arm)
  local v1 = ((n - 1.0) / n) * value + 0.00001
  local v2 = (1.0 / n) * reward + 0.00001
  local new_value = v1 + v2 + 0.00001
  -- local new_value = value + reward

  ngx.log(ngx.NOTICE, "n          -> " .. n)
  ngx.log(ngx.NOTICE, "value      -> " .. value)
  ngx.log(ngx.NOTICE, "v1         -> " .. v1)
  ngx.log(ngx.NOTICE, "v2         -> " .. v2)
  ngx.log(ngx.NOTICE, "new_value  -> " .. new_value)

  common.set_value(ngx.shared.beacons, "test2:weight:" .. chosen_arm, new_value)
end

function ind_max(values)

  local max_value = 0.0
  local max_value_index = 1

  for k, v in pairs(values) do
    -- ngx.log(ngx.NOTICE, "v -> " .. v)
    -- ngx.log(ngx.NOTICE, "max_value -> " .. max_value)
    -- ngx.log(ngx.NOTICE, "max_value_index -> " .. max_value_index)

    if v > max_value then
      max_value = v
      max_value_index = k
    end
  end

  return max_value_index
end

