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

local have_name = function(obj)
  if pcall(function() return obj.name end) then return obj.name end
end

Table_to_str.to_richtext = function(obj, as_key)
  local s = {}
  local t = type(obj)
  if t == 'table' and type(obj.__self) == 'userdata' and obj.object_name then
    if have_name(obj) then return '"[color=cyan]'..obj.name..'[/color]"' end
    return '[color=purple]'..obj.object_name..'[/color]'
  elseif t == 'table' then
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
    return '"[color=1,0.7,1,1]'..esc(obj)..'[/color]"'
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
  if not global.players then return end
  local g = global.players[player.index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  local list = {}
  local success = {}
  for s in str:gmatch('[-%a_]+') do
    list[s:gsub('[-]','_'):lower()] = true
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
