-- 그래픽 유저 인터페이스

local Util = require('modules.util')

local Gui = {}

local eventnames = {}
for k, _ in pairs(defines.events) do
  table.insert(eventnames, k)
end
table.sort(eventnames, function(a,b) return a < b end)

Gui.toggle_frame = function(event)
  local player = game.players[event.player_index]
  if not player.admin and game.is_multiplayer() then return end
  if not global.players then global.players = {} end
  if not global.players[event.player_index] then
    global.players[event.player_index] = {}
  end

  local g = global.players[event.player_index]
  g.index = event.player_index

  local frame = player.gui.screen._0_event_trace_frame_
  local exframe = player.gui.screen._0_event_trace_exframe_
  local imframe = player.gui.screen._0_event_trace_imframe_

  if exframe and exframe.valid then exframe.destroy() end
  if imframe and imframe.valid then imframe.destroy() end
  if frame and frame.valid then
    frame.destroy()
    g.logging = false
    return
  end

  frame = player.gui.screen.add{type = 'frame', name = '_0_event_trace_frame_', direction = 'vertical', style = 'frame_0-event-trace'}
  if g.gui then
    for k in pairs(g.gui) do g.gui[k] = nil end
  end
  g.gui = {frame = frame}
  if g.logchoice == nil then
    g.logging = true
    g.logchoice = true
  else
    g.logging = g.logchoice
  end
  if not g.counter then
    g.counter = Util.copytbl(defines.events)
    for k in pairs(g.counter) do g.counter[k] = 0 end
  else
    for k in pairs(g.counter) do g.counter[k] = 0 end
  end
  if not g.last_width then g.last_width = 900 end
  if not g.last_height then g.last_height = 600 end

  if not g.whitelist then
    g.whitelist = {}
    for i, k in pairs(eventnames) do
      if k ~= 'on_tick' then
        g.whitelist[k] = true
      else
        g.whitelist[k] = false
      end
    end
  end

  if g.log_to_gvv == nil then g.log_to_gvv = false end

  frame.location = {0,0}
  frame.style.horizontally_stretchable = true
  frame.style.width = g.last_width
  frame.style.height = g.last_height

  local top = frame.add{type = 'frame', style = 'frame-bg_0-event-trace'}
  top.style.top_padding = 4
  top.style.right_padding = 8
  top.style.left_padding = 8
  top.add{type = 'flow', name = 'header', direction = 'horizontal'}
  top.header.drag_target = frame
  top.header.style.vertically_stretchable = false
  top.header.style.horizontal_spacing = 8
  top.header.add{type = 'label', name = 'title', caption = {"",{"0-event-trace-title"},' ',script.active_mods['0-event-trace']}, style = 'frame_title'}
  top.header.title.drag_target = frame
  local drag = top.header.add{type = 'empty-widget', name = 'dragspace', style = 'draggable_space_header'}
  drag.drag_target = frame
  drag.style.right_margin = 8
  drag.style.height = 24
  drag.style.horizontally_stretchable = true
  drag.style.vertically_stretchable = true
  top.header.add{type = 'sprite-button', name = 'minimize', sprite = 'utility/collapse', style = 'frame_action_button', mouse_button_filter = {'left'}, tooltip = {"0-event-trace-minimize"}}
  g.gui.minimize = top.header.minimize -- 사용자 개체 등록
  local closebtn = top.header.add{type = 'sprite-button', name = 'closebtn', sprite = 'utility/close_white', style = 'frame_action_button', mouse_button_filter = {'left'}, tooltip = {"0-event-trace-close-tooltip"}}
  g.gui.closebtn = closebtn -- 사용자 개체 등록

  local middle = frame.add{type = 'flow', direction = 'horizontal', style = 'hflow_0-event-trace'}
  middle.add{type = 'empty-widget', name = 'left', style = 'empty-frame-bg_0-event-trace'}
  middle.left.style.width = 5
  middle.left.style.vertically_stretchable = true
  middle.add{type = 'frame', name = 'w', style = 'inside-wrap_0-event-trace'}
  local innerframe = middle.w.add{type = 'frame', direction = 'vertical', style = 'inside_deep_frame_0-event-trace'}
  middle.add{type = 'empty-widget', name = 'right', style = 'empty-frame-bg_0-event-trace'}
  middle.right.style.width = 5
  middle.right.style.vertically_stretchable = true

  local bottom = frame.add{type = 'empty-widget', style = 'empty-frame-bg_0-event-trace'}
  bottom.style.height = 5
  bottom.style.horizontally_stretchable = true

  local topspace = innerframe.add{type = 'flow', name = 'topspace', direction = 'horizontal'}
  topspace.style.padding = 6
  topspace.style.horizontal_spacing = 6
  topspace.style.vertical_align = 'center'
  local switch_state
  if g.logging then
    switch_state = 'right'
  else
    switch_state = 'left'
  end
  topspace.add{type = 'switch', name = 'logswitch', switch_state = switch_state, allow_none_state = false,
    left_label_caption = 'OFF', right_label_caption = 'ON', tooltip = {"0-event-trace-toggle-logging-tooltip"},
    left_label_tooltip = {"0-event-trace-off-logging-tooltip"},
    right_label_tooltip = {"0-event-trace-on-logging-tooltip"}
  }
  topspace.add{type = 'label', caption = 'W : ', tooltip = {"0-event-trace-xresize"}}
  topspace.add{type = 'slider', name = 'xresize', minimum_value = 425, maximum_value = 1625, value = g.last_width,
    value_step = 25, discrete_slider = false, discrete_values = true}
  topspace.xresize.style.width = 80
  topspace.add{type = 'label', caption = 'H : ', tooltip = {"0-event-trace-yresize"}}
  topspace.add{type = 'slider', name = 'yresize', minimum_value = 275, maximum_value = 1475, value = g.last_height,
    value_step = 25, discrete_slider = false, discrete_values = true}
  topspace.yresize.style.width = 80
  g.gui.logswitch = topspace.logswitch -- 사용자 개체 등록
  g.gui.xresize = topspace.xresize -- 사용자 개체 등록
  g.gui.yresize = topspace.yresize -- 사용자 개체 등록

  local tabpane = innerframe.add{type = 'tabbed-pane', style = 'tabbed_pane_0-event-trace'}
  tabpane.style.horizontally_stretchable = true

  --로그 log 탭
  local tab1 = tabpane.add{type = 'tab', name = 'tab1', caption = {"0-event-trace-tab-log"}}
  local cwrap1 = tabpane.add{type = 'flow', direction = 'vertical'}
  cwrap1.style.horizontally_stretchable = true
  cwrap1.style.vertically_stretchable = true
  tabpane.add_tab(tab1,cwrap1)
  cwrap1.add{type = 'flow', name = 'w', direction = 'vertical', style = 'vflow_0-event-trace'}
  cwrap1.w.add{type = 'empty-widget', name = 'fill', style = 'empty-tabbed_pane_frame-bg_0-event-trace'}
  cwrap1.w.fill.style.height = 8
  local outpane = cwrap1.w.add{type = 'scroll-pane', direction = 'vertical', vertical_scroll_policy='auto',
    horizontal_scroll_policy = 'never', style='scroll_pane_0-event-trace',
  }
  g.gui.outpane = outpane -- 사용자 개체 등록

  --설정 settings 탭
  local tab2 = tabpane.add{type = 'tab', name = 'tab2', caption = {"0-event-trace-tab-setting"}}
  local cwrap2 = tabpane.add{type = 'flow', direction = 'vertical'}
  cwrap2.style.horizontally_stretchable = true
  cwrap2.style.vertically_stretchable = true
  tabpane.add_tab(tab2,cwrap2)
  tabpane.selected_tab_index = 1
  cwrap2.add{type = 'flow', name = 'w', direction = 'vertical', style = 'vflow_0-event-trace'}
  cwrap2.w.style.vertical_spacing = 5
  cwrap2.w.add{type = 'empty-widget', name = 'fill', style = 'empty-tabbed_pane_frame-bg_0-event-trace'}
  cwrap2.w.fill.style.height = 8
  local fixedset1 = cwrap2.w.add{type = 'flow', direction = 'horizontal'}
  fixedset1.style.left_padding = 6
  fixedset1.style.vertical_align = 'center'
  fixedset1.add{type = 'sprite', sprite = 'utility/search_white'}
  fixedset1.add{type = 'textfield', name = 'search', numeric = false, clear_and_focus_on_right_click = true, tooltip = {"0-event-trace-search-tooltip"}}
  g.gui.white_search = fixedset1.search -- 사용자 개체 등록

  local fixedset2 = cwrap2.w.add{type = 'flow', direction = 'horizontal'}
  fixedset2.style.left_padding = 6
  fixedset2.style.vertical_align = 'center'
  Util.add_label_w_style(fixedset2, {"0-event-trace-whitelist"}, nil, {font = 'default-bold'})
  fixedset2.add{type = 'sprite-button', name = 'import', sprite = 'utility/import', style = 'tool_button', tooltip = {"0-event-trace-import-tooltip"}}
  fixedset2.add{type = 'sprite-button', name = 'export', sprite = 'utility/export', style = 'tool_button', tooltip = {"0-event-trace-export-tooltip"}}

  g.gui.wimport = fixedset2.import -- 사용자 개체 등록
  g.gui.wexport = fixedset2.export -- 사용자 개체 등록

  local fixedset3 = cwrap2.w.add{type = 'flow', direction = 'horizontal'}
  fixedset3.style.left_padding = 6
  fixedset3.style.horizontal_spacing = 15
  fixedset3.add{type = 'radiobutton', name = 'selall', state = false, caption = {"0-event-trace-selectall"}}
  fixedset3.add{type = 'radiobutton', name = 'deselall', state = false, caption = {"0-event-trace-deselectall"}}
  fixedset3.add{type = 'radiobutton', name = 'invert', state = false, caption = {"0-event-trace-invert"}}

  g.gui.white_selall = fixedset3.selall -- 사용자 개체 등록
  g.gui.white_deselall = fixedset3.deselall -- 사용자 개체 등록
  g.gui.white_invert = fixedset3.invert -- 사용자 개체 등록

  cwrap2.w.add{type = 'line', direction = 'horizontal'}
  local scrollset = cwrap2.w.add{type = 'scroll-pane', direction = 'vertical', vertical_scroll_policy='auto',
    horizontal_scroll_policy = 'never', style='scroll_pane-thickthumb_0-event-trace',
  }

  local settable = scrollset.add{type = 'table', name = '_0_event_trace_whitelist_', column_count = 1}
  g.gui.whitelist = settable -- 사용자 개체 등록
  local align = settable.style.column_alignments
  align[1] = 'bottom-left'

  for i, k in ipairs(eventnames) do
    if k ~= 'on_tick' then
      settable.add{type = 'checkbox', name = k, state = g.whitelist[k], caption = k}
    else
      settable.add{type = 'checkbox', name = k, state = false, caption = '[color=0.5,0.5,0.5,0.5]'..k..'[/color]', ignored_by_interaction = true, enabled = false}
    end
  end


  local mini = frame.add{type = 'frame', name = 'mini', direction = 'horizontal', style = 'inside_deep_frame_0-event-trace'}
  g.gui.mini = mini -- 사용자 개체 등록
  mini.style.vertical_align = 'bottom'
  mini.style.padding = 2
  mini.drag_target = frame
  mini.visible = false
  mini.style.horizontally_stretchable = true
  mini.style.vertically_stretchable = true
  mini.add{type = 'checkbox', name = 'miniswitch', state = g.logging, tooltip = {"0-event-trace-toggle-logging-tooltip"}}
  mini.miniswitch.style.top_margin = 2
  mini.add{type = 'label', name = 'minicaption', caption = 'event'}
  mini.minicaption.drag_target = frame
  mini.add{type = 'sprite-button', name = 'unminimize', sprite = 'utility/reset_white', style = 'frame_action_button', mouse_button_filter = {'left'}, tooltip = {"0-event-trace-minimize-revert"}}
  mini.unminimize.style.width = 18
  mini.unminimize.style.height = 18
  g.gui.miniswitch = mini.miniswitch -- 사용자 개체 등록
  g.gui.unminimize = mini.unminimize -- 사용자 개체 등록



  if not _gvv_recognized_ then return end

  local tab3 = tabpane.add{type = 'tab', name = 'tab3', caption = {"0-event-trace-tab-gvv-setting"}}
  local cwrap3 = tabpane.add{type = 'flow', direction = 'vertical'}
  cwrap3.style.horizontally_stretchable = true
  cwrap3.style.vertically_stretchable = true
  tabpane.add_tab(tab3,cwrap3)
  cwrap3.add{type = 'flow', name = 'w', direction = 'vertical', style = 'vflow_0-event-trace'}
  cwrap3.w.style.vertical_spacing = 5
  cwrap3.w.add{type = 'empty-widget', name = 'fill', style = 'empty-tabbed_pane_frame-bg_0-event-trace'}
  cwrap3.w.fill.style.height = 8
  local tab3set1 = cwrap3.w.add{type = 'scroll-pane', direction = 'vertical', vertical_scroll_policy='auto',
    horizontal_scroll_policy = 'never', style='scroll_pane-thickthumb_0-event-trace',
  }
  tab3set1.style.left_padding = 6
  tab3set1.style.horizontally_stretchable = true

  tab3set1.add{type = 'checkbox', name = 'gvvlog', state = g.log_to_gvv, caption = {"0-event-trace-gvvlog"}}
  tab3set1.add{type = 'label', caption = {"",'[font=default-bold]',{"0-event-trace-gvvlog-man"},'[/font]'}}
  tab3set1.add{type = 'drop-down', name = 'gvvdel_select',
    items = eventnames, selected_index = g.gvv_event_selected_index, style = 'dropdown_0-event-trace',
  }
  tab3set1.gvvdel_select.style.horizontally_squashable = true
  tab3set1.add{type = 'label', caption = {"0-event-trace-gvvlog-getcode"}}
  tab3set1.add{type = 'textfield', name = 'gvvget_code', text = '',
    clear_and_focus_on_right_click = true, tooltip = {"0-event-trace-right-click-to-select-all"}
  }
  tab3set1.gvvget_code.style.bottom_margin = 10
  tab3set1.gvvget_code.style.maximal_width = 9999
  tab3set1.gvvget_code.style.horizontally_stretchable = true
  tab3set1.gvvget_code.style.horizontally_squashable = true
  tab3set1.add{type = 'label', name = 'gvvget_code_hiddenbuffer'}
  tab3set1.gvvget_code_hiddenbuffer.visible = false
  local tab3s1wrap1 = tab3set1.add{type = 'flow', direction = 'horizontal'}
  tab3s1wrap1.add{type = 'textfield', name = 'gvvdel_range_input', text = ''}
  tab3s1wrap1.gvvdel_range_input.style.width = 80
  tab3s1wrap1.add{type = 'button', name = 'gvvdel_range_btn', caption = {"0-event-trace-gvvdel_range_input"}}
  tab3s1wrap1.gvvdel_range_btn.style.width = 200
  local tab3s1wrap2 = tab3set1.add{type = 'flow', direction = 'horizontal'}
  tab3s1wrap2.style.top_margin = 6
  tab3s1wrap2.add{type = 'textfield', name = 'gvvdel_from_input', text = '',
    numeric = true, allow_negative = false, allow_decimal = false,
  }
  tab3s1wrap2.gvvdel_from_input.style.width = 80
  tab3s1wrap2.add{type = 'button', name = 'gvvdel_from_btn', caption = {"0-event-trace-gvvdel_from_input"}}
  tab3s1wrap2.gvvdel_from_btn.style.width = 200
  tab3set1.add{type = 'button', name = 'gvvclear_btn', caption = {"0-event-trace-gvvclear"}}
  tab3set1.gvvclear_btn.style.top_margin = 20

  local eventname = tab3set1.gvvdel_select.items[tab3set1.gvvdel_select.selected_index]
  if not eventname then eventname = '' end
  tab3set1.gvvget_code.text = 'remote.call("__gvv__0-event-trace","get","'..player.name..'","'..eventname..'",1)'
  tab3set1.gvvget_code_hiddenbuffer.caption = tab3set1.gvvget_code.text

  g.gui.gvvlog = tab3set1.gvvlog -- 사용자 개체 등록
  g.gui.gvvdel_select = tab3set1.gvvdel_select -- 사용자 개체 등록
  g.gui.gvvget_code = tab3set1.gvvget_code -- 사용자 개체 등록
  g.gui.gvvdel_range_input = tab3s1wrap1.gvvdel_range_input -- 사용자 개체 등록
  g.gui.gvvdel_range_btn = tab3s1wrap1.gvvdel_range_btn -- 사용자 개체 등록
  g.gui.gvvdel_from_input = tab3s1wrap2.gvvdel_from_input -- 사용자 개체 등록
  g.gui.gvvdel_from_btn = tab3s1wrap2.gvvdel_from_btn -- 사용자 개체 등록
  g.gui.gvvclear_btn = tab3set1.gvvclear_btn -- 사용자 개체 등록


end

Gui.toggle_logging = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  if g.gui.logswitch.switch_state == 'left' then
    g.gui.logswitch.switch_state = 'right'
    g.logchoice = true
    g.logging = true
    g.gui.miniswitch.state = true
  else
    g.gui.logswitch.switch_state = 'left'
    g.logchoice = false
    g.logging = false
    g.gui.miniswitch.state = false
  end
end

return Gui
