--gvv 사용

local gvv = {}

------------------
local lua_code = [[

if not global['0-event-trace'] then global['0-event-trace'] = {} end
remote.add_interface('__gvv__0-event-trace',{
  add = function(player_name, eventname, eventdata)
    local h = global['0-event-trace']
    if not h then global['0-event-trace'] = {} h = global['0-event-trace'] end
    if not h[player_name] then
      h[player_name] = {}
      local eventnames = {}
      for k, v in pairs(defines.events) do
        table.insert(eventnames, k)
      end
      table.sort(eventnames, function(a,b) return a < b end)
      for i, k in ipairs(eventnames) do
        if not h[player_name][k] then h[player_name][k] = {last_index = 0} end
      end
    end
    if not h[player_name][eventname] then h[player_name][eventname] = {last_index = 0} end
    h = h[player_name]
    local e = h[eventname]
    if e.last_index > 99999999999998 then e.last_index = 0 end
    local i = e.last_index + 1
    local j = i
    local f = {}
    for d = 1, 5 do
      f[d] = i%10
      i = (i - i%10)/10
    end
    -- 5차원 index 폴더를 생성한다.
    -- result ex) index = 20513 then eventname[2][0][5][1][3] = eventdata
    for d = 5, 1, -1 do
      if not e[f[d] ] then e[f[d] ] = {} end
      if d == 1 then
        e[f[d] ] = eventdata
        break
      end
      e = e[f[d] ]
    end
    h[eventname].last_index = j
    return j
  end,
})

]] ---------------

gvv.loader = function()
  if script.active_mods['gvv'] then
    local pc, ret = pcall(function() remote.call('__gvv__gvv','c',lua_code) end)
    if pc then
      _gvv_recognized_ = true
    else
      log(ret)
    end
  end
end

return gvv
