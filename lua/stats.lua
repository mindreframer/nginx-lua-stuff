local lustache = require "lustache"
local common = require 'common'

function dump_stats(candidate, n)

  local reports = {
    name = candidate,
    reports = {}
  }

  local shm = ngx.shared.beacons
  local key_for_total_pv = candidate .. ":pv:total"
  local key_for_total_click = candidate .. ":click:total"

  local total_pv = common.value_for_key(shm, key_for_total_pv)
  local total_click = common.value_for_key(shm, key_for_total_click)
  local total_ctr = 0

  if total_pv > 0 then
    total_ctr = 100 * total_click / total_pv
  end

  reports['reports'][1] = {
    name          = 'total',
    pv            = total_pv,
    click         = total_click,
    ctr           = string.format("%.2f", total_ctr),
    pv_percent    = 100,
    click_percent = 100,
    weight        = "n/a",
  }

  for i = 1, n do

    local key_for_pv = candidate .. ":pv:" .. i
    local key_for_click = candidate .. ":click:" .. i
    local key_for_weight = candidate .. ":weight:" .. i

    --ngx.log(ngx.NOTICE, "get pv     -> " .. key_for_pv)
    --ngx.log(ngx.NOTICE, "get click  -> " .. key_for_click)

    local pv = common.value_for_key(shm, key_for_pv)
    local click = common.value_for_key(shm, key_for_click)
    local weight = common.value_for_key(shm, key_for_weight)

    ngx.log(ngx.NOTICE, "weight -> " .. weight)
  
    pv = pv or 0 
    click = click or 0 

    local ctr = 0.0
    local pv_percent = 0.0
    local click_percent = 0.0

    if pv > 0 then
      pv_percent = 100 * pv / total_pv 
    end

    if click > 0 then
      click_percent = 100 * click / total_click
    end

    if pv > 0 then
      ctr = 100 * click / pv
    end

    reports['reports'][i + 1] = {
      name          = "case: " .. i,
      pv            = pv,
      click         = click,
      ctr           = string.format("%.2f", ctr),
      pv_percent    = string.format("%.2f", pv_percent),
      click_percent = string.format("%.2f", click_percent),
      weight        = string.format("%.6f", weight)
    }
  end

  return reports
end

local report = {
  candidates = {
    dump_stats("test1", 3), 
    dump_stats("test2", 4),
    dump_stats("test_css", 2),
    dump_stats("test_items", 3)
  }
}


local template = common.readAll('/workspace/stats.mustache')
output = lustache:render(template, report)
ngx.say(output)
