-- GUI 이벤트

local Table_to_str = require('modules.table_to_str')
local Util = require('modules.util')

local Gui_Event = {}

local export_window = function(player_index)
  if not storage.players then return end
  local g = storage.players[player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  local player = game.players[player_index]

  if g.gui.exframe and g.gui.exframe.valid then
    g.gui.exframe.destroy()
  end
  if g.gui.imframe and g.gui.imframe.valid then
    g.gui.imframe.destroy()
  end

  local exframe, closebtn, innerframe = Util.create_frame_w_closebtn(player, '_0_event_trace_exframe_', {"0-event-trace-export-window-title"})
  g.gui.exframe = exframe
  g.gui.exclosebtn = closebtn
  innerframe.add{type = 'text-box', name = 'textarea', text = Table_to_str.export_whitelist(g.whitelist), clear_and_focus_on_right_click = false}
  innerframe.textarea.focus()
  innerframe.textarea.select_all()
  innerframe.textarea.style.width = 400
  innerframe.textarea.style.height = 300

  player.opened = exframe
end

local import_window = function(player_index)
  if not storage.players then return end
  local g = storage.players[player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  local player = game.players[player_index]

  if g.gui.exframe and g.gui.exframe.valid then
    g.gui.exframe.destroy()
  end
  if g.gui.imframe and g.gui.imframe.valid then
    g.gui.imframe.destroy()
  end

  local imframe, closebtn, innerframe = Util.create_frame_w_closebtn(player, '_0_event_trace_imframe_', {"0-event-trace-import-window-title"})
  g.gui.imframe = imframe
  g.gui.imclosebtn = closebtn
  innerframe.add{type = 'text-box', name = 'textarea', text = '', clear_and_focus_on_right_click = false}
  innerframe.textarea.focus()
  innerframe.textarea.style.width = 400
  innerframe.textarea.style.height = 300
  g.gui.imtext = innerframe.textarea
  local right = innerframe.add{type = 'flow', direction = 'horizontal'}
  right.style.horizontal_align = 'right'
  right.style.horizontally_stretchable = true
  g.gui.imconf = right.add{type = 'button', caption = {"0-event-trace-confirm-import-btn"}, style = 'confirm_button'}

  player.opened = imframe
end

local gvv_range_del = function(g)
  if g.gui.gvvdel_range_input and g.gui.gvvdel_range_input.valid and g.gui.gvvdel_select and g.gui.gvvdel_select.valid then
    local player = game.players[g.index]
    local dropdown = g.gui.gvvdel_select
    local istart, iend = g.gui.gvvdel_range_input.text:match('^%s*(%d+)%s*%-%s*(%d+)%s*$')
    if not istart then
      istart = g.gui.gvvdel_range_input.text:match('^%s*(%d+)%s*$')
      iend = nil
    end
    if not istart then
      player.print('input positive integer. format : #-# to delete range, # to delete 1')
      return
    end
    istart = istart + 0
    if iend then iend = iend + 0
    else iend = istart
    end
    local eventname = dropdown.items[dropdown.selected_index]
    if not eventname or eventname == '' then
      player.print('select event id')
      return
    end
    local pc, ret = pcall(function() return remote.call('__gvv__0-event-trace','del', player.name, eventname, istart, iend) end)
    if pc then
      if type(ret) == 'string' then player.print(ret)
      elseif ret == nil then
        player.print('(gvv) deleted event-trace "[color=yellow]'..eventname..'[/color]" log of range [color=cyan]'..istart..' - '..iend..'[/color] of player [color=yellow]'..player.name..'[/color]')
      end
    else
      player.print(ret)
    end
  end
end

local gvv_from_del = function(g)
  if g.gui.gvvdel_from_input and g.gui.gvvdel_from_input.valid and g.gui.gvvdel_select and g.gui.gvvdel_select.valid then
    local player = game.players[g.index]
    local dropdown = g.gui.gvvdel_select
    local istart = g.gui.gvvdel_from_input.text:match('^%s*(%d+)%s*$')
    if not istart then
      player.print('input positive integer')
      return
    end
    istart = istart + 0
    local eventname = dropdown.items[dropdown.selected_index]
    if not eventname or eventname == '' then
      player.print('select event id')
      return
    end
    local pc, ret = pcall(function() return remote.call('__gvv__0-event-trace','del', player.name, eventname, istart, nil) end)
    if pc then
      if type(ret) == 'string' then player.print(ret)
      elseif ret == nil then
        player.print('(gvv) deleted event-trace "[color=yellow]'..eventname..'[/color]" log of range [color=cyan]'..istart..' - end[/color] of player [color=yellow]'..player.name..'[/color]')
      end
    else
      player.print(ret)
    end
  end
end

local gvv_clear = function(g)
  local player = game.players[g.index]
  local pc, ret = pcall(function() return remote.call('__gvv__0-event-trace','clear', player.name) end)
  if pc then
    if type(ret) == 'string' then player.print(ret)
    elseif ret == nil then
      player.print('(gvv) cleared event-trace log of all events of player '..player.name)
    end
  else
    player.print(ret)
  end
end

Gui_Event.on_gui_click = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.closebtn then
    g.gui.frame.destroy()
    g.logging = false
    if g.gui.exframe and g.gui.exframe.valid then
      g.gui.exframe.destroy()
    end
    if g.gui.imframe and g.gui.imframe.valid then
      g.gui.imframe.destroy()
    end
  elseif event.element == g.gui.minimize then
    for _, elem in pairs(g.gui.frame.children) do
      elem.visible = false
    end
    g.gui.mini.visible = true
    g.gui.frame.style.width = 78
    g.gui.frame.style.height = 22
    g.gui.frame.location = {g.gui.frame.location.x + g.last_width - 88,g.gui.frame.location.y + 3}
  elseif event.element == g.gui.unminimize then
    for _, elem in pairs(g.gui.frame.children) do
      elem.visible = true
    end
    g.gui.mini.visible = false
    g.gui.frame.style.width = g.last_width
    g.gui.frame.style.height = g.last_height
    g.gui.frame.location = {0,0}
  elseif event.element == g.gui.wexport then
    export_window(event.player_index)
  elseif event.element == g.gui.wimport then
    import_window(event.player_index)
  elseif event.element == g.gui.exclosebtn then
    g.gui.exframe.destroy()
  elseif event.element == g.gui.imclosebtn then
    g.gui.imframe.destroy()
  elseif event.element == g.gui.imconf then
    local player = game.players[event.player_index]
    Table_to_str.import_whitelist(player, g.gui.imtext.text)
    g.gui.imframe.destroy()
    g.gui.white_selall.state = false
    g.gui.white_deselall.state = false
  elseif event.element == g.gui.gvvdel_range_btn then
    gvv_range_del(g)
  elseif event.element == g.gui.gvvdel_from_btn then
    gvv_from_del(g)
  elseif event.element == g.gui.gvvclear_btn then
    gvv_clear(g)
  end
end

Gui_Event.on_gui_value_changed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.xresize then
    g.last_width = g.gui.xresize.slider_value
    g.gui.frame.style.width = g.last_width
  elseif event.element == g.gui.yresize then
    g.last_height = g.gui.yresize.slider_value
    g.gui.frame.style.height = g.last_height
  end
end

Gui_Event.on_gui_switch_state_changed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.logswitch then
    if g.gui.logswitch.switch_state == 'right' then
      g.logchoice = true
      g.logging = true
      g.gui.miniswitch.state = true
    else
      g.logchoice = false
      g.logging = false
      g.gui.miniswitch.state = false
    end
  end
end

Gui_Event.on_gui_checked_state_changed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.white_selall then
    g.gui.white_deselall.state = false
    for _, child in pairs(g.gui.whitelist.children) do
      if child.name ~= 'on_tick' and child.visible then
        g.whitelist[child.name] = true
        child.state = true
      end
    end
  elseif event.element == g.gui.white_deselall then
    g.gui.white_selall.state = false
    for _, child in pairs(g.gui.whitelist.children) do
      if child.name ~= 'on_tick' and child.visible then
        g.whitelist[child.name] = false
        child.state = false
      end
    end
  elseif event.element == g.gui.white_invert then
    event.element.state = false
    g.gui.white_selall.state = false
    g.gui.white_deselall.state = false
    for _, child in pairs(g.gui.whitelist.children) do
      if child.name ~= 'on_tick' and child.visible then
        g.whitelist[child.name] = not child.state
        child.state = not child.state
      end
    end
  elseif event.element and event.element.valid and event.element.parent == g.gui.whitelist then
    g.whitelist[event.element.name] = event.element.state
    g.gui.white_selall.state = false
    g.gui.white_deselall.state = false
  elseif event.element == g.gui.gvvlog then
    g.log_to_gvv = event.element.state
  elseif event.element == g.gui.miniswitch then
    if g.gui.miniswitch.state then
      g.gui.logswitch.switch_state = 'right'
      g.logchoice = true
      g.logging = true
    else
      g.gui.logswitch.switch_state = 'left'
      g.logchoice = false
      g.logging = false
    end
  end
end

Gui_Event.on_gui_text_changed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  local noerror, r
  if event.element == g.gui.white_search then
    g.gui.white_selall.state = false
    g.gui.white_deselall.state = false
    local str = event.element.text
    str = str:gsub('^%s*(.-)%s*$', '%1')
    str = str:gsub('[-_]', '')
    if str == '' then
      for _, child in pairs(g.gui.whitelist.children) do
        child.visible = true
      end
    else
      str = str:lower()
      for _, child in pairs(g.gui.whitelist.children) do
        noerror, r = pcall(string.match,child.name:gsub('[-_]', ''),str)
        if noerror and r then
          child.visible = true
        else
          child.visible = false
        end
      end
    end
  elseif event.element == g.gui.gvvget_code then
    local name = event.element.name..'_hiddenbuffer'
    local buffer = event.element.parent[name]
    event.element.text = buffer.caption
    event.element.focus()
    event.element.select_all()
  end
end

Gui_Event.on_gui_closed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.exframe then
    g.gui.exframe.destroy()
  end
  if event.element == g.gui.imframe then
    g.gui.imframe.destroy()
  end
end

Gui_Event.on_gui_confirmed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.gvvdel_range_input then
    gvv_range_del(g)
  elseif event.element == g.gui.gvvdel_from_input then
    gvv_from_del(g)
  end
end

Gui_Event.on_gui_selection_state_changed = function(event)
  if not event.element then return end
  if event.element.player_index ~= event.player_index then return end
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.gvvdel_select then
    g.gvv_event_selected_index = event.element.selected_index
    if g.gui.gvvget_code and g.gui.gvvget_code.valid then
      local player = game.players[event.player_index]
      local eventname = event.element.items[event.element.selected_index]
      g.gui.gvvget_code.text = 'remote.call("__gvv__0-event-trace","get","'..player.name..'","'..eventname..'",1)'
      local name = g.gui.gvvget_code.name
      g.gui.gvvget_code.parent[name..'_hiddenbuffer'].caption = g.gui.gvvget_code.text
    end
  end
end

return Gui_Event
