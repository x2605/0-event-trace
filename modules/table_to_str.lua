local Table_to_str = {}

local esc = function(s)
  local ic = {'\\', '"', "'", '\a', '\b', '\f', '\n', '\r', '\t', '\v'}
  local oc = {'\\', '"', "'", 'a', 'b', 'f', 'n', 'r', 't', 'v'}
  for i, c in ipairs(ic) do
    s = s:gsub(c, '\\'..oc[i])
  end
  return s
end

local keyname = function(k)
  if k ~= k:match('^[%a_][%a%d_]*') then
    return '["'..k..'"]'
  end
  return k
end

local nil2empty = function(s) if s == nil then return '' end return s end

local unicode_len = function(s)
  local r = true
  local c, cs = 0, 0
  while r do
    s, c = s:gsub('^[%z\1-\127\194-\244][\128-\191]*','')
    cs = cs + c
    if c == 0 then r = false end
  end
  return cs
end

local unicode_front = function(s,l)
  local r, sn = true, ''
  local c, cs = 0, 0
  while r do
    sn = sn .. nil2empty(s:match('^[%z\1-\127\194-\244][\128-\191]*'))
    s, c = s:gsub('^[%z\1-\127\194-\244][\128-\191]*','')
    cs = cs + c
    if c == 0 or cs >= l then r = false end
  end
  return sn
end

local unicode_end = function(s,l)
  local r, sn = true, ''
  local c, cs = 0, 0
  while r do
    sn = nil2empty(s:match('[%z\1-\127\194-\244][\128-\191]*$')) .. sn
    s, c = s:gsub('[%z\1-\127\194-\244][\128-\191]*$','')
    cs = cs + c
    if c == 0 or cs >= l then r = false end
  end
  return sn
end

local shorten_if_long = function(s)
  if unicode_len(s) > 30 then
    return unicode_front(s,13)..' ··· '..unicode_end(s,13)
  end
  return s
end

local have = function(prob,obj)
  if pcall(function() return obj[prob] end) then return obj[prob] end
end

Table_to_str.to_richtext = function(obj, as_key)
  local s = {}
  local t = type(obj)
  if t == 'userdata' and obj.object_name then
    if have('name',obj) and obj.name ~= '' then return '"[color=cyan]'..obj.name..'[/color]"'
    elseif have('id',obj) then return '[color=purple]'..obj.object_name..'[/color][color=blue].id='..obj.id..'[/color]'
    elseif have('group_number',obj) then return '[color=purple]'..obj.object_name..'[/color][color=blue].group_number='..obj.group_number..'[/color]'
    elseif have('tag_number',obj) and have('text',obj) then return '[color=purple]'..obj.object_name..'[/color][color=blue].tag_number='..obj.tag_number..', text="'..shorten_if_long(obj.text)..'"[/color]'
    elseif have('index',obj) then return '[color=purple]'..obj.object_name..'[/color][color=blue].index='..obj.index..'[/color]'
    end
    return '[color=purple]'..obj.object_name..'[/color]'
  elseif t == 'table' and not as_key then
    s[#s + 1] = '{'
    for k, v in pairs(obj) do
      if #s > 1 then s[#s + 1] = ', ' end
      if type(k) ~= 'number' then
        s[#s + 1] = Table_to_str.to_richtext(k, true)
        s[#s + 1] = '='
      end
      s[#s + 1] = Table_to_str.to_richtext(v)
    end
    s[#s + 1] = '}'
    return table.concat(s)
  elseif t == 'string' then
    if as_key then return keyname(esc(obj)) end
    return '"[color=1,0.7,1,1]'..shorten_if_long(esc(obj))..'[/color]"'
  elseif t == 'number' then
    return '[color=1,1,0.7,1]'..tostring(obj)..'[/color]'
  elseif t == 'boolean' then
    if as_key then return '[[color=0.7,1,0.7,1]'..tostring(obj)..'[/color]]' end
    return '[color=0.7,1,0.7,1]'..tostring(obj)..'[/color]'
  elseif t == 'nil' then
    if as_key then return '[[color=0.7,0.7,0.7,1]nil[/color]]' end
    return '[color=0.7,0.7,0.7,1]nil[/color]'
  else
    if as_key then return '[[color=1,0.3,0.3,1]'..t..'[/color]]' end
    return '[color=1,0.3,0.3,1]'..t..'[/color]'
  end
end

Table_to_str.export_whitelist = function(list)
  local i = 0
  local s = {}
  for k, v in pairs(list) do
    if v then
      if i > 0 then s[#s + 1] = '\n' end
      s[#s + 1] = k
      i = i + 1
    end
  end
  if #s > 0 then s[#s + 1] = '\n' end
  return table.concat(s)
end

Table_to_str.import_whitelist = function(player, str)
  if not storage.players then return end
  local g = storage.players[player.index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  local list = {}
  local success = {}
  for s in str:gmatch('[%g]+') do
    list[s] = true
  end
  for k, _ in pairs(g.whitelist) do
    if k ~= 'on_tick' then
      if list[k] then
        g.whitelist[k] = true
        g.gui.whitelist[k].state = true
        success[k] = true
        list[k] = nil
      else
        g.whitelist[k] = false
        g.gui.whitelist[k].state = false
      end
    end
  end
  player.print{"0-event-trace-import-message", table_size(success)}
  if table_size(list) > 0 then
    local r = {}
    for k, _ in pairs(list) do
      if #r > 0 then r[#r + 1] = ', ' end
      r[#r + 1] = k
    end
    player.print{"0-event-trace-import-fail-message", table_size(list), table.concat(r)}
  end
end

return Table_to_str
