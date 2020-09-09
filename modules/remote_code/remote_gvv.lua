return [[if not global['0-event-trace'] then global['0-event-trace'] = {} end

_0_event_trace_function_ = {}
_0_event_trace_function_.index_to_5dim_folders = function(i)
  local f = {}
  for d = 1, 5 do
    f[d] = i%10
    i = (i - i%10)/10
  end
  return f
end
_0_event_trace_function_.deepcopy = function(ori)
  local t = type(ori)
  local ret
  if t == 'table' and type(ori.__self) == 'userdata' and ori.object_name then
    ret = ori
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
    if type(v) == 'table' and type(v.__self) == 'userdata' and v.object_name and _0_event_trace_function_.have('valid',v) then
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
      if _0_event_trace_function_.have('position',v) then if not e[t] then e[t] = {} end
        e[t].position = _0_event_trace_function_.deepcopy(game.players[v].position)
      end
      if _0_event_trace_function_.have('surface',v) then if not e[t] then e[t] = {} end
        e[t].surface = _0_event_trace_function_.deepcopy(game.players[v].surface.name)
      end
    end
  end
  return e
end

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
    local e = h[player_name][eventname]
    if e.last_index > 99999999999998 then e.last_index = 0 end
    local j = e.last_index + 1
    local f = _0_event_trace_function_.index_to_5dim_folders(j)
    -- create 5-dimensional index folder
    -- result ex) index = 120513 then eventname[12][0][5][1][3] = eventdata
    for d = 5, 1, -1 do
      if not e[f[d] ] then e[f[d] ] = {} end
      if d == 1 then
        e[f[d] ] = _0_event_trace_function_.attach_past(eventdata)
        break
      end
      e = e[f[d] ]
    end
    h[player_name][eventname].last_index = j
    return j
  end,

  clear = function(player_name)
    local h = global['0-event-trace']
    if not h or not h[player_name] then return end
    for k, v in pairs(h[player_name]) do
      if type(v) == 'table' and not getmetatable(v) then
        h[player_name][k] = {last_index = 0}
      end
    end
  end,

  del = function(player_name, eventname, istart, iend)
    local h = global['0-event-trace']
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
          for i = fstart[digit] + 1, fend[digit] - 1, 1 do
            folder_s[i] = nil
          end
          iterator(digit - 1, folder_s[fstart[digit] ], folder_s[fend[digit] ], pstart * 10 + fstart[digit], pend * 10 + fend[digit])
        end
      else
        local fs, fe
        if type(folder_s) == 'table' then
          for i = fstart[digit] + 1, 9, 1 do
            folder_s[i] = nil
          end
          fs = folder_s[fstart[digit] ]
        end
        if type(folder_e) == 'table' then
          for i = 0, fend[digit] - 1, 1 do
            folder_e[i] = nil
          end
          fe = folder_e[fend[digit] ]
        end
        iterator(digit - 1, fs, fe, pstart * 10 + fstart[digit], pend * 10 + fend[digit])
      end
    end
    iterator(5, e, e, 0, 0)
    pcall(function() e[fstart[5] ][fstart[4] ][fstart[3] ][fstart[2] ][fstart[1] ] = nil end)
    if type(e[fstart[5] ]) == 'table' and table_size(e[fstart[5] ]) == 0 then
      e[fstart[5] ] = nil
    elseif type(e[fstart[5] ]) == 'table' then
      if type(e[fstart[5] ][fstart[4] ]) == 'table' and table_size(e[fstart[5] ][fstart[4] ]) == 0 then
        e[fstart[5] ][fstart[4] ] = nil
      elseif type(e[fstart[5] ][fstart[4] ]) == 'table' then
        if type(e[fstart[5] ][fstart[4] ][fstart[3] ]) == 'table' and table_size(e[fstart[5] ][fstart[4] ][fstart[3] ]) == 0 then
          e[fstart[5] ][fstart[4] ][fstart[3] ] = nil
        elseif type(e[fstart[5] ][fstart[4] ][fstart[3] ]) == 'table' then
          if type(e[fstart[5] ][fstart[4] ][fstart[3] ][fstart[2] ]) == 'table' and table_size(e[fstart[5] ][fstart[4] ][fstart[3] ][fstart[2] ]) == 0 then
            e[fstart[5] ][fstart[4] ][fstart[3] ][fstart[2] ] = nil
          end
        end
      end
    end
    pcall(function() e[fend[5] ][fend[4] ][fend[3] ][fend[2] ][fend[1] ] = nil end)
    if type(e[fend[5] ]) == 'table' and table_size(e[fend[5] ]) == 0 then
      e[fend[5] ] = nil
    elseif type(e[fend[5] ]) == 'table' then
      if type(e[fend[5] ][fend[4] ]) == 'table' and table_size(e[fend[5] ][fend[4] ]) == 0 then
        e[fend[5] ][fend[4] ] = nil
      elseif type(e[fend[5] ][fend[4] ]) == 'table' then
        if type(e[fend[5] ][fend[4] ][fend[3] ]) == 'table' and table_size(e[fend[5] ][fend[4] ][fend[3] ]) == 0 then
          e[fend[5] ][fend[4] ][fend[3] ] = nil
        elseif type(e[fend[5] ][fend[4] ][fend[3] ]) == 'table' then
          if type(e[fend[5] ][fend[4] ][fend[3] ][fend[2] ]) == 'table' and table_size(e[fend[5] ][fend[4] ][fend[3] ][fend[2] ]) == 0 then
            e[fend[5] ][fend[4] ][fend[3] ][fend[2] ] = nil
          end
        end
      end
    end
    if iend == 99999999999999 then
      if istart > 0 then
        e.last_index = istart - 1
      else
        e.last_index = 0
      end
    end
  end,

  get = function(player_name, eventname, index)
    local h = global['0-event-trace']
    if not h or not h[player_name] or not h[player_name][eventname] then return end
    if type(index) ~= 'number' then return end
    local e = h[player_name][eventname]
    local f = _0_event_trace_function_.index_to_5dim_folders(index)
    if e[f[5] ] and e[f[5] ][f[4] ] and e[f[5] ][f[4] ][f[3] ] and e[f[5] ][f[4] ][f[3] ][f[2] ] then
      return e[f[5] ][f[4] ][f[3] ][f[2] ][f[1] ]
    end
  end,
})
]]

-- 문자열 코드
