return [[if not storage['0-event-trace'] then storage['0-event-trace'] = {} end

_0_event_trace_digits_ = 5
_0_event_trace_function_ = {}
_0_event_trace_function_.index_to_5dim_folders = function(i)
  local f = {}
  for d = 1, _0_event_trace_digits_ do
    if d == _0_event_trace_digits_ then
      f[d] = i
    else
      f[d] = i%10
    end
    i = (i - i%10)/10
  end
  return f
end
local blacklist = { --Causing savefile corruption 세이브파일 고장냄
  LuaLazyLoadedValue = true,
  LuaItemStack = true,
}
_0_event_trace_function_.deepcopy = function(ori)
  local t = type(ori)
  local ret
  if t == 'userdata' and ori.object_name then
    if blacklist[ori.object_name] then
      ret = ori.object_name
    else
      ret = ori
    end
  elseif t == 'table' then
    ret = {}
    for k, v in next, ori, nil do
      ret[_0_event_trace_function_.deepcopy(k)] = _0_event_trace_function_.deepcopy(v)
    end
  else
    ret = ori
  end
  return ret
end
_0_event_trace_function_.have = function(prob,obj)
  if pcall(function() return obj[prob] end) then return obj[prob] end
end
_0_event_trace_function_.attach_past = function(e)
  local t
  for k, v in pairs(e) do
    t = '_T_'..k
    if type(v) == 'userdata' and v.object_name and _0_event_trace_function_.have('valid',v) then
      if _0_event_trace_function_.have('name',v) then if not e[t] then e[t] = {} end
        e[t].name = _0_event_trace_function_.deepcopy(v.name)
      end
      if _0_event_trace_function_.have('type',v) then if not e[t] then e[t] = {} end
        e[t].type = _0_event_trace_function_.deepcopy(v.type)
      end
      if _0_event_trace_function_.have('index',v) then if not e[t] then e[t] = {} end
        e[t].index = _0_event_trace_function_.deepcopy(v.index)
      end
      if _0_event_trace_function_.have('position',v) then if not e[t] then e[t] = {} end
        e[t].position = _0_event_trace_function_.deepcopy(v.position)
      end
      if _0_event_trace_function_.have('surface',v) then if not e[t] then e[t] = {} end
        e[t].surface = _0_event_trace_function_.deepcopy(v.surface.name)
      end
      if _0_event_trace_function_.have('id',v) then if not e[t] then e[t] = {} end
        e[t].id = _0_event_trace_function_.deepcopy(v.id)
      end
      if _0_event_trace_function_.have('group_id',v) then if not e[t] then e[t] = {} end
        e[t].group_id = _0_event_trace_function_.deepcopy(v.group_id)
      end
      if _0_event_trace_function_.have('group_number',v) then if not e[t] then e[t] = {} end
        e[t].group_number = _0_event_trace_function_.deepcopy(v.group_number)
      end
      if _0_event_trace_function_.have('tag_number',v) then if not e[t] then e[t] = {} end
        e[t].tag_number = _0_event_trace_function_.deepcopy(v.tag_number)
      end
      if _0_event_trace_function_.have('unit_number',v) then if not e[t] then e[t] = {} end
        e[t].unit_number = _0_event_trace_function_.deepcopy(v.unit_number)
      end
      if _0_event_trace_function_.have('ghost_unit_number',v) then if not e[t] then e[t] = {} end
        e[t].ghost_unit_number = _0_event_trace_function_.deepcopy(v.ghost_unit_number)
      end
    elseif k == 'player_index' and type(v) == 'number' then
      if _0_event_trace_function_.have('position',game.players[v]) then if not e[t] then e[t] = {} end
        e[t].position = _0_event_trace_function_.deepcopy(game.players[v].position)
      end
      if _0_event_trace_function_.have('surface',game.players[v]) then if not e[t] then e[t] = {} end
        e[t].surface = _0_event_trace_function_.deepcopy(game.players[v].surface.name)
      end
    end
  end
  return e
end

remote.add_interface('__gvv__0-event-trace',{
  add = function(player_name, eventname, eventdata)
    local h = storage['0-event-trace']
    if not h then storage['0-event-trace'] = {} h = storage['0-event-trace'] end
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
    local e = h[player_name][eventname]
    if e.last_index > 99999999999998 then e.last_index = 0 end
    local j = e.last_index + 1
    local f = _0_event_trace_function_.index_to_5dim_folders(j)
    -- create 5-dimensional index folder
    -- result ex) index = 120513 then eventname[12][0][5][1][3] = eventdata
    for d = _0_event_trace_digits_, 1, -1 do
      if not e[f[d] ] then e[f[d] ] = {} end
      if d == 1 then
        e[f[d] ] = _0_event_trace_function_.deepcopy(_0_event_trace_function_.attach_past(eventdata))
        break
      end
      e = e[f[d] ]
    end
    h[player_name][eventname].last_index = j
    return j
  end,

  clear = function(player_name)
    local h = storage['0-event-trace']
    if not h or not h[player_name] then return end
    for k, v in pairs(h[player_name]) do
      if type(v) == 'table' and not getmetatable(v) then
        h[player_name][k] = {last_index = 0}
      end
    end
  end,

  del = function(player_name, eventname, istart, iend)
    local h = storage['0-event-trace']
    if not h or not h[player_name] or not h[player_name][eventname] then return 'no table created yet' end
    local e = h[player_name][eventname]
    if istart == nil and iend == nil then
      h[player_name][eventname] = {last_index = 0}
      return
    end
    if type(istart) ~= 'number' or istart < 0 or istart%1 ~= 0 then return 'istart is invalid' end
    if iend == nil then iend = 99999999999999 end
    if type(iend) ~= 'number' or iend < 0 or iend%1 ~= 0 then return 'iend is invalid' end
    if iend < istart then return 'iend must be equal to or bigger than istart' end
    local fstart = _0_event_trace_function_.index_to_5dim_folders(istart)
    local fend = _0_event_trace_function_.index_to_5dim_folders(iend)
    local iterator
    iterator = function(digit, folder_s, folder_e, pstart, pend)
      if digit == 0 then return end
      if pstart == pend then
        if type(folder_s) == 'table' then
          for i in pairs(folder_s) do
            if type(i) == 'number' and i > fstart[digit] and i < fend[digit] then
              folder_s[i] = nil
            end
          end
          iterator(digit - 1, folder_s[fstart[digit] ], folder_s[fend[digit] ], pstart * 10 + fstart[digit], pend * 10 + fend[digit])
        end
      else
        local fs, fe
        if type(folder_s) == 'table' then
          for i in pairs(folder_s) do
            if type(i) == 'number' and i > fstart[digit] then
              folder_s[i] = nil
            end
          end
          fs = folder_s[fstart[digit] ]
        end
        if type(folder_e) == 'table' then
          for i in pairs(folder_e) do
            if type(i) == 'number' and i < fend[digit] then
              folder_e[i] = nil
            end
          end
          fe = folder_e[fend[digit] ]
        end
        iterator(digit - 1, fs, fe, pstart * 10 + fstart[digit], pend * 10 + fend[digit])
      end
    end
    iterator(_0_event_trace_digits_, e, e, 0, 0)
    local remove_entry = function(ftbl)
      pcall(function()
        local t = e
        for i = _0_event_trace_digits_, 1, -1 do
          if i > 1 then t = t[ftbl[i] ]
          else t[ftbl[1] ] = nil
          end
        end
      end)
      for i = 2, _0_event_trace_digits_ do
        pcall(function()
          local t = e
          for ii = _0_event_trace_digits_, i + 1, -1 do
            t = t[ftbl[ii] ]
          end
          if table_size(t[ftbl[i] ]) == 0 then t[ftbl[i] ] = nil end
        end)
      end
    end
    remove_entry(fstart)
    remove_entry(fend)
    if iend == 99999999999999 then
      if istart > 0 then
        e.last_index = istart - 1
      else
        e.last_index = 0
      end
    end
  end,

  get = function(player_name, eventname, index)
    local h = storage['0-event-trace']
    if not h or not h[player_name] or not h[player_name][eventname] then return end
    if type(index) ~= 'number' then return end
    local e = h[player_name][eventname]
    local f = _0_event_trace_function_.index_to_5dim_folders(index)
    local pc, ret = pcall(function()
      local t = e
      for i = _0_event_trace_digits_, 1, -1 do
        t = t[f[i] ]
      end
      return t
    end)
    if pc then return ret end
  end,

  get_last_index = function(player_name, eventname)
    local h = storage['0-event-trace']
    if not h or not h[player_name] or not h[player_name][eventname] then return end
    return h[player_name][eventname].last_index
  end,
})
]]

-- 문자열 코드
