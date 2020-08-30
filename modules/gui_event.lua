-- GUI 이벤트

local Table_to_str = require('modules.table_to_str')
local Util = require('modules.util')

local Gui_Event = {}

local export_window = function(player_index)
  if not global.players then return end
  local g = global.players[player_index]
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
  if not global.players then return end
  local g = global.players[player_index]
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

Gui_Event.on_gui_click = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if not event.element then return end
  if event.element == g.gui.closebtn then
    g.gui.frame.destroy()
    g.logging = false
    if g.gui.exframe and g.gui.exframe.valid then
      g.gui.exframe.destroy()
    end
    if g.gui.imframe and g.gui.imframe.valid then
      g.gui.imframe.destroy()
    end
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
  end
end

Gui_Event.on_gui_value_changed = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
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
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.logswitch then
    if g.gui.logswitch.switch_state == 'right' then
      g.logchoice = true
      g.logging = true
    else
      g.logchoice = false
      g.logging = false
    end
  end
end

Gui_Event.on_gui_checked_state_changed = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
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
  end
end

Gui_Event.on_gui_text_changed = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
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
        if string.match(child.name:gsub('[-_]', ''), str) then
          child.visible = true
        else
          child.visible = false
        end
      end
    end
  end
end

Gui_Event.on_gui_closed = function(event)
  if not event.element then return end
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if event.element == g.gui.exframe then
    g.gui.exframe.destroy()
  end
  if event.element == g.gui.imframe then
    g.gui.imframe.destroy()
  end
end

return Gui_Event
